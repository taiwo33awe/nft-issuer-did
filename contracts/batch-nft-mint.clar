;; This Clarity contract manages the issuance, burning, and transferring of Digital Identity (DID) 
;; non-fungible tokens (NFTs). It provides the following functionalities:
;; 1. Minting single or batch NFTs with specified URIs.
;; 2. Updating token URIs.
;; 3. Transferring NFTs between principals.
;; 4. Burning NFTs with checks to ensure proper ownership and non-burned status.
;; 5. Read-only functions to retrieve token information like URI, owner, and burn status.
;;
;; The contract ensures that only the token owner can burn, transfer, or update the token URI. 
;; Additionally, it enforces limits on the batch minting size and ensures token URIs are valid before being set.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-exists (err u102))
(define-constant err-token-not-found (err u103))
(define-constant err-invalid-token-uri (err u104))
(define-constant err-burn-failed (err u105))
(define-constant err-already-burned (err u106))
(define-constant err-not-token-owner-update (err u107))
(define-constant err-invalid-batch-size (err u108))
(define-constant err-batch-mint-failed (err u109))
(define-constant max-batch-size u100)

;; Data Variables
(define-non-fungible-token did-nft uint)
(define-data-var last-token-id uint u0)

;; Maps
(define-map token-uri uint (string-ascii 256))
(define-map burned-tokens uint bool)
(define-map token-metadata uint (string-ascii 256))

;; Private Functions
(define-private (is-valid-uri (uri (string-ascii 256)))
  (let ((uri-length (len uri)))
    (and (>= uri-length u1)
         (<= uri-length u256))))

(define-private (is-token-burned? (token-id uint))
  (default-to false (map-get? burned-tokens token-id)))

(define-private (mint-did (uri-data (string-ascii 256)))
  (let ((new-token-id (+ (var-get last-token-id) u1)))
    (asserts! (is-valid-uri uri-data) err-invalid-token-uri)
    (try! (nft-mint? did-nft new-token-id tx-sender))
    (map-set token-uri new-token-id uri-data)
    (var-set last-token-id new-token-id)
    (ok new-token-id)))

(define-private (mint-did-in-batch (uri (string-ascii 256)) (accumulated (list 100 uint)))
  (match (mint-did uri)
    success (unwrap-panic (as-max-len? (append accumulated success) u100))
    error accumulated))

;; Public Functions

(define-public (burn (token-id uint))
  (let ((token-owner (unwrap! (nft-get-owner? did-nft token-id) err-token-not-found)))
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (not (is-token-burned? token-id)) err-already-burned)
    (try! (nft-burn? did-nft token-id token-owner))
    (map-set burned-tokens token-id true)
    (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq recipient tx-sender) err-not-token-owner)
    (let ((actual-sender (unwrap! (nft-get-owner? did-nft token-id) err-not-token-owner)))
      (asserts! (is-eq actual-sender sender) err-not-token-owner)
      (try! (nft-transfer? did-nft token-id sender recipient))
      (ok true))))

(define-public (update-token-uri (token-id uint) (new-uri (string-ascii 256)))
  (begin
    (let ((token-owner (unwrap! (nft-get-owner? did-nft token-id) err-token-not-found)))
      (asserts! (is-eq token-owner tx-sender) err-not-token-owner-update)
      (asserts! (is-valid-uri new-uri) err-invalid-token-uri)
      (map-set token-uri token-id new-uri)
      (ok true))))

;; Read-Only Functions
(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? token-uri token-id)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? did-nft token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (is-burned (token-id uint))
  (ok (is-token-burned? token-id)))

(define-read-only (get-batch-token-ids (start-id uint) (count uint))
  (ok (map uint-to-response 
    (unwrap-panic (as-max-len? 
      (list-tokens start-id count) 
      u100)))))

(define-private (uint-to-response (id uint))
  {
    token-id: id,
    uri: (unwrap-panic (get-token-uri id)),
    owner: (unwrap-panic (get-owner id)),
    burned: (unwrap-panic (is-burned id))
  })

(define-private (list-tokens (start uint) (count uint))
  (map + 
    (list start) 
    (generate-sequence count)))

(define-private (generate-sequence (length uint))
  (map - (list length)))

;; Contract initialization
(begin
  (var-set last-token-id u0))
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


# Clarinet 2.0 Smart Contract - DID Token Management

This Clarinet 2.0 smart contract is designed to handle the management of non-fungible tokens (NFTs) in a decentralized identity (DID) system. The contract allows for the minting, burning, and transferring of NFTs, as well as managing metadata and URIs associated with tokens. It provides both public and read-only functions, ensuring secure interaction with the blockchain and efficient token management.

## Features

- **Minting**: Allows users to mint new tokens with associated URIs and metadata.
- **Burning**: Allows token owners to burn their tokens securely, marking them as destroyed.
- **Transfers**: Enables secure transfers of tokens between users.
- **Token Metadata Management**: Allows users to update the URI associated with a specific token.
- **Batch Minting**: Facilitates minting multiple tokens in a single transaction.
- **Querying**: Offers read-only functions to get details about tokens, their owners, and their burn status.

## Functions

### Public Functions

1. **burn(token-id)**  
   Burn a specific token if the caller is the owner of the token and it hasn't already been burned.

2. **transfer(token-id, sender, recipient)**  
   Transfer a token from the sender to the recipient, provided the sender is the current owner of the token.

3. **update-token-uri(token-id, new-uri)**  
   Update the URI associated with a specific token if the caller is the token's owner.

### Private Functions

- **is-valid-uri(uri)**  
   Validates if a given URI is within the acceptable length range (1 to 256 characters).

- **is-token-burned?(token-id)**  
   Checks if a specific token has been burned.

- **mint-did(uri-data)**  
   Mints a new DID token with the specified URI data.

- **mint-did-in-batch(uri, accumulated)**  
   Mints a batch of DID tokens.

### Read-Only Functions

1. **get-token-uri(token-id)**  
   Retrieve the URI of a specific token.

2. **get-owner(token-id)**  
   Get the owner of a specific token.

3. **get-last-token-id()**  
   Get the ID of the last minted token.

4. **is-burned(token-id)**  
   Check if a token has been burned.

5. **get-batch-token-ids(start-id, count)**  
   Get a batch of token IDs starting from a given ID.

### Constants

- **contract-owner**: The address that owns the contract.
- **err-owner-only**: Error code when a function is accessed by a non-owner.
- **err-not-token-owner**: Error code when a non-owner attempts to interact with a token.
- **err-token-exists**: Error code when trying to mint a token that already exists.
- **err-token-not-found**: Error code when a token is not found.
- **err-invalid-token-uri**: Error code for invalid token URI.
- **err-burn-failed**: Error code when burning a token fails.
- **err-already-burned**: Error code when trying to burn an already burned token.
- **err-not-token-owner-update**: Error code when trying to update a token by a non-owner.
- **err-invalid-batch-size**: Error code when the batch size exceeds the maximum allowed.
- **err-batch-mint-failed**: Error code for batch minting failure.
- **max-batch-size**: Maximum batch size for minting tokens.

## Contract Variables

- **did-nft**: The non-fungible token representing the DID.
- **last-token-id**: The ID of the last minted token.
- **token-uri**: A mapping of token IDs to their associated URI.
- **burned-tokens**: A mapping that tracks which tokens have been burned.
- **token-metadata**: A mapping of token IDs to their associated metadata.

## How to Deploy

1. Clone the repository to your local machine:
    ```bash
    git clone <repository-url>
    cd <contract-directory>
    ```

2. Use Clarinet to deploy the contract to the network:
    ```bash
    clarinet deploy
    ```

3. Interact with the contract using the Clarinet CLI or integrate it with your front-end application.

## License

This smart contract is licensed under the MIT License. See the LICENSE file for more information.


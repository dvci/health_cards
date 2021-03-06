# The Core Classes

## HealthCards::HealthCard
> Represents a single health card
> allows a fhir_bundle payload and uses VerifiableCredential to compress. raw inputs may also be provided

**API**
- `::new`
- `::from_jws`
- `::from_payload`
- `::compress_payload`
- `#to_hash`
- `#to_json`
- `#to_s`

## HealthCards::JWS
> Takes a payload and signs it as a JWS

**API**
- `::new`
- `::from_jws`
- `#verify`
- `#kid`
- `#header`
- `#signature`
- `#payload`

## HealthCards::Issuer
> Issues health cards based on a stored private key
> Issuer uses HealthCard

**API**
- `::new`
- `#create_health_card`
- `#issue_jws`
- `#key` // Returns HealthCards::PrivateKey
- `#key=`
- `#to_jwk` // Returns HealthCard::KeySet as JWK

## HealthCards::Verifier
> Verify health cards based on a stored public key
> Verifiers may contain one or more public keys (using KeySet)

**API**
- `::new`
- `#keys_as_jwk`
- `#add_keys`
- `#remove_keys`
- `#verify`
- `#resolve_keys=`
- `#resolves_keys?`

# Other Classes/ Helper classes

## HealthCards::KeySet
> Represents a set of keys

**API**
- `::new`
- `#add_keys`
- `#remove_keys`
- `#keys`
- `#to_jwk` // Option `include_private_keys` off by default
- `#include?`

## HealthCards::Key
> Represents a cryptographic key

**API**
- `::new`
- `::generate_key`
- `::from_file`
- `::load_from_or_create_file`
- `::from_json`
- `#to_json`
- `#to_jwk`
- `#kid`
- `#public_key`

## HealthCards::PrivateKey < Key
> Represents a private key

**API**
- `#sign`

## HealthCards::PublicKey < Key
> Represents a public key

**API**
- `#verify`

## HealthCards::QRCodes
> Represents a set of QR Codes that map to a single JWS

**API**
- `::from_JWS`
- `::new`
- `#chunks`
- `#code_by_ordinal`
- `#to_jws`

## HealthCards::QRCodes::Chunks
> Represents a single QR Code from a single chunk of a JWS

**API**
- `::new`
- `#data`
- `#image`

# Modules

## HealthCards::ChunkingUtils
> Implements chunking specific functionality for transforming between raw JWS and QR encoded strings

**API**
- `::split_bundle`
- `::jws_to_qr_chunks`
- `::qr_chunks_to_jws`

# Classes *outside* the library

## COVIDHealthCard
> Responsible for transforming the FHIR bundle payload to meet the COVID Vaccinations Data Minimization Profile
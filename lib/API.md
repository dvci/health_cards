# The Core Classes

## HealthCards::HealthCard
> Represents a single health card
> allows a fhir_bundle payload and uses VerifiableCredential to compress. raw inputs may also be provided

**API**
- `::new`
- `::from_jws`
- `::globally_resolve_keys=`
- `::globally_resolves_keys?`
- `#to_jws`
- `#save_to_file`
- `#save_as_qr_code`
- `#verify`
- `#resolve_keys=`
- `#resolves_keys?`
- `#key=`
- `#key`
- `#public_key=`
- `#public_key`

## HealthCards::Issuer
> Issues health cards based on a stored private key
> Issuer uses HealthCard

**API**
- `::new`
- `#create_health_card`
- `#key` // Returns HealthCards::PrivateKey
- `#key=`

## HealthCards::Verifier
> Verify health cards based on a stored public key
> Verifiers may contain one or more public keys (using KeySet)

**API**
- `::new`
- `#keys_as_jwk`
- `#add_key`
- `#remove_key`
- `#verify`
- `#resolve_keys=`
- `#resolves_keys?`
- `::verify`


# Other Classes/ Helper classes

## HealthCards::VerifiableCredential
> Represents the FHIR Payload as a Verifiable Credential Object responsible
> for minifying & compressing bundle

**API**
- `::new`
- `#credential`


## HealthCards::JWS
> Takes a payload and signs it as a JWS provides JWS functionality to HealthCard

**API**
- `::new`
- `::from_jws`
- `#to_jws`
- `#verify`
- `#header`
- `#signature`
- `#payload`

## HealthCards::KeySet
> Represents a set of keys

**API**
- `::new`
- `#add_key`
- `#remove_key`
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
- `#thumbprint`
- `#public_key`

## HealthCards::PrivateKey < Key
> Represents a private key

**API**
- `#sign`

## HealthCards::PublicKey < Key
> Represents a public key

**API**
- `#verify`

# Modules

## HealthCards::Chunking
> Provides methods for performing jws chunking for QR codes

**API**
- `#split_bundle`
- `#generate_qr_chunks`


# Classes *outside* the library

## COVIDHealthCard
> Responsible for munging the FHIR payload to meet the FHIR Profile
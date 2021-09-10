# Usage

## Issuing SMART Health Cards

```ruby
# Generate or load a private key
key = HealthCards::Key.generate_key # or `key = HealthCards::Key.from_file`

# Create an Issuer
issuer = HealthCards::Issuer.new(key: key)

# Create Health Cards with the Issuer

health_card = issuer.create_health_card(FHIR::Bundle.new)
covid_health_card = issuer.create_health_card(FHIR::Bundle.new, type: COVIDHealthCard)

# Create JWS with the Issuer. The Bundle will be converted into a HealthCad and used as 
# a payload for the JWS

jws = issuer.issue_jws(FHIR::Bundle.new)

## Verifying SMART Health Cards

```ruby
# Generate a Verifier

verifier = HealthCards::Verifier.new

# Keys can also be removed. (internally this is done through matching JWK kids)
# verifier.remove_key(key)
jws = 'foofoofoo.barbarbar.bazbazbaz'

# By default the verifier will search for and resolve public keys to verify credentials
verifier.verify(jws)
```

## Manually Operation

Most applications will want to use the library from `Issuer` or `Verifier`.
Health Cards can also be manually created and verified if more control is needed.

### Manually Creating a Health Card

```ruby
# Generate or load a private key
key = HealthCards::Key.generate_key # or `key = HealthCards::Key.from_file`

# Create the Health Card
health_card = HealthCards::HealthCard.new(issuer: "http://example-issuer.com", bundle: FHIR::Bundle.new)

```

### Manually Verifying a JWS
JWS representing a Health Card can also be manually verified.

```ruby
jws = 'foofoofoo.barbarbar.bazbazbaz'

# Create JWS from JWS string
JWS = HealthCards::JWS.from_jws(jws)

# A key can be manually added to verify if needed
jws.public_key = public_key

# JWS will verify using the included public_key
jws.verify
```

## Configuration

### Custom Health Cards

An application might want to issue specific types of Health Cards. 
Custom `HealthCard` or `Issuer` class can be created to customize their behavior.
`HealthCard` provides hooks for adding functionality to the health card.

```ruby

# Subclass the base `HealthCard` class to add specific behavior and/or set IG specific requirements
class CustomHealthCard < HealthCards::HealthCard
  fhir_version '4.0.1' # Sets FHIR version
  additional_types 'https://my.custom.cards#type' #Adds additional claim types to those required by SMART Health Cards
  allow FHIR::Patient, %w[name] #Specify allowed attributes for FHIR resources
end

### Disable Public Key Resolution

**Should the global configuration be prefixed with `globally_`? e.g. `HealthCards.globally_resolve_keys = false`**

#### Globally
Public key resolution can be configured across the library. This will affect the public key resolution
for all classes and instances, including `Issuer` and `HealthCard
```ruby
# The current state can be checked with:
HealthCards.resolves_keys?

# Public Key resolution can be disabled with
HealthCards.resolve_keys=false
```

#### Verifier and HealthCard
Public Key resolution can be disabled for all `Verifier` instances with:
```ruby
# The current state can be checked with:
HealthCards::Verifier.resolves_keys?

# Public key resolution can be disabled with
HealthCards::Verifier.resolve_keys=false
```

Public key resolution can be disabled for a single instance issuer with:
```ruby
verifier = HealthCards::Verifier.new

# The current state can be checked with:
verifier.resolves_keys?
# Public key resolution can be disabled with
verifier.resolve_keys = false

# Keys can be manually added that the verifier can use to verify credentials
key = HealthCards::Key.load_file('my_keys.pem')
verifier.add_key(key) # this only requires the public key so `verifier.add_key(key.public_key)` works too
```

The `HealthCard` supports these features as well.

## QR Codes

A QR Code can be created from either a set of encoded strings (from scanning QR Codes) or a JWS (object or string).

```ruby

jws = 'foofoofoo.barbarbar.bazbazbaz'

qr_codes = HealthCards::QRCodes.from_jws(jws)

# Chunks would normally be longer but are truncated here for readability
chunks = ['shc:/1/2/1234123412341234', 'shc:/2/2/2345234523452345']

qr_codes = Healthcards::QRCodes.new(chunks)
```
Each QRCodes object contains an array of 'chunks' which each represent an individual QR Code.
Each chunk contains an ordinal integer representing their position, along with a chunk of data. These can be converted to images (PNGs) and saved or displayed.

```ruby

# Save to File
qr_codes.chunks.each do |chunk|
  chunk.image.save("qr-code-#{chunk.ordinal}.png")
end

```
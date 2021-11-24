# Usage

## Issuing SMART Health Cards

```ruby
# Generate or load a private key
key = HealthCards::Key.generate_key # or `key = HealthCards::Key.from_file`

# Create an Issuer
issuer = HealthCards::Issuer.new(key: key)

# Create Health Cards with the Issuer, Using :type will apply rules defined by the Payload
# subclass

health_card = issuer.issue_health_card(FHIR::Bundle.new)
covid_health_card = issuer.issue_health_card(FHIR::Bundle.new, type: COVIDPayload)

# Create JWS with the Issuer. 

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

## Creating/Using a Health Card

HealthCards encapsulate a data in a JWS in order to faciliate the use of the data by systems
that want to use/evaluate a card.

```
  # While local health cards should be created by an Issuer, you may receive a JWS
  # from an external system. A HealthCard can be created manually using only a JWS
  jws = 'foofoofoo.barbarbar.bazbazbaz'
  health_card = HealthCards::HealthCard.new(jws)

  # Access QR Codes

  health_card.qr_codes

  # Render QR Code to a PNG

  health_card.code_by_ordinal(1).image

  # Extract immunizations from a HealthCard
  immunizations = health_card.resources(type: FHIR::Immunization)

  # Extract a single resource from a HealthCard

  patient = health_card.resource(type: FHIR::Patient)

  # Extract a resource meeting certain conditions
  acceptable_code_list = %w(207, 208, 210)

  health_card.resources(type: FHIR::Immunization) { |imm| acceptable_code_list.include?(imm.vaccineCode) }
```

## Manually Operation

Most applications will want to use the library from `Issuer` or `Verifier`.
Health Cards can also be manually created and verified if more control is needed.

### Manually Verifying a JWS or HealthCard
JWS or HealthCard can also be manually verified.

```ruby
jws = 'foofoofoo.barbarbar.bazbazbaz'

# Create JWS from JWS string
JWS = HealthCards::JWS.from_jws(jws)

# A key can be manually added to verify if needed
jws.public_key = public_key

# JWS will verify using the included public_key
jws.verify

health_card = HealthCards::HealthCard.new(jws)
health_card.verify

```

## Configuration

### Custom Health Cards

An application might want to issue specific types of Health Cards. 
Custom `Payload` or `Issuer` class can be created to customize their behavior.
`Payload` provides hooks for adding functionality to the health card.

```ruby

# Subclass the base `Payload` class to add specific behavior and/or set IG specific requirements
class CustomHealthCard < HealthCards::Payload
  fhir_version '4.0.1' # Sets FHIR version
  additional_types 'https://my.custom.cards#type' #Adds additional claim types to those required by SMART Health Cards
  allow FHIR::Patient, %w[name] #Specify allowed attributes for FHIR resources
end

### Disable Public Key Resolution

**Should the global configuration be prefixed with `globally_`? e.g. `HealthCards.globally_resolve_keys = false`**

#### Globally
Public key resolution can be configured across the library. This will affect the public key resolution
for all classes and instances, including `Issuer` and `Payload
```ruby
# The current state can be checked with:
HealthCards.resolves_keys?

# Public Key resolution can be disabled with
HealthCards.resolve_keys=false
```

#### Verifier and Payload
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
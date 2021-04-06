# Usage

## Issuing SMART Health Cards

```ruby
# Generate or load a private key
key = HealthCards::Key.generate_key # or `key = HealthCards::Key.from_file`

# Create an Issuer
issuer = HealthCards::Issuer.new(key: key)

# Create Health Cards with the Issuer

health_card = issuer.create_health_card(FHIR::Patient.new)
health_card_2 = issuer.create_health_card('{"resourceType": "Patient"}')

# These health cards can be converted to a JWS or downloaded as a file

health_card.to_jws
health_card.save_to_file('./example.smart-health-card')
```

## Verifying SMART Health Cards

```ruby
# Generate a Verifier

verifier = HealthCards::Verifier.new

# Keys can also be removed. (internally this is done through matching JWK thumbprints)
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
health_card = HealthCards::HealthCard.new(payload: FHIR::Patient.new, key: key)
health_card.to_jws

# Can also verify the Health Card
health_card.verify
```

### Manually Verifying a HealthCard
JWS representing a Health Card can also be manually verified

```ruby
jws = 'foofoofoo.barbarbar.bazbazbaz'

# Create Health Card from JWS
health_card = HealthCards::HealthCard.from_jws(jws)

# By default the health_card will attempt to resolve keys to verify the payload
health_card.resolves_keys?
# We can disable that with:
health_card.resolve_keys = false
# Note this can also be globally disabled with
health_card.globally_resolve_keys = 

# A key can be manually added to verify if needed
health_card.public_key = public_key

health_card.verify
```

## Configuration

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
Public Key resolution can be disabled for all Verifiers or Health Cards with:
```ruby
# The current state can be checked with:
HealthCards::Verifier.resolves_keys?

# Public key resolution can be disabled with
HealthCards::Verifier.resolve_keys=false
```

Public key resolution can be disabled for a single instance issuer with:
```ruby
verifier = HealthCards::Verifier.new

# Public key resolution:
verifier.resolves_keys?

verifier.resolve_keys = false

# Keys can be manually added that the verifier can use to verify credentials
key = HealthCards::Key.load_file('my_keys.pem')
verifier.add_key(key) # this only requires the public key so `verifier.add_key(key.public_key)` works too
```
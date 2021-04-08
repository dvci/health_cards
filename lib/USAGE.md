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

# By default a HealthCard will attempt to resolve keys to verify the payload
health_card.verify
```

### Manually Verifying a HealthCard
JWS representing a Health Card can also be manually verified

```ruby
jws = 'foofoofoo.barbarbar.bazbazbaz'

# Create Health Card from JWS
health_card = HealthCards::HealthCard.from_jws(jws)

# A key can be manually added to verify if needed
health_card.public_key = public_key

# By default a HealthCard will attempt to resolve keys to verify the payload
health_card.verify
```

## Configuration

### Custom Health Cards

An application might want to issue specific types of Health Cards. 
Custom `HealthCard` or `Issuer` class can be created to customize their behavior.
`HealthCard` provides hooks for adding functionality to the health card.

```ruby

# Subclass the base `HealthCard` class to add specific behavior
class CustomHealthCard < HealthCards::HealthCard
  def preprocess_bundle_hook(bundle)
    bundle.id = "customprefix-#{bundle.id}"
  end
end

# Create an Issuer that creates `CustomHealthCard` instances
custom_issuer = HealthCards::Issuer.new(key: private_key, health_card_type: CustomHealthCard)
```

Currently, only one hook exists:

- `#preprocess_bundle_hook`

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
# Health Cards

![Build](https://github.com/dvci/health_cards/actions/workflows/ruby.yml/badge.svg)
![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)
![Test Coverage](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/test_coverage)

Health Cards is a Ruby gem that implements [SMART Health Cards](https://smarthealth.cards), a secure and decentralized framework that allows people to prove their vaccination status or medical test results. It is built on top of [FHIR 4](https://hl7.org/FHIR/) healthcare interoperability standards and converts medical data into a [JWS](https://en.wikipedia.org/wiki/JSON_Web_Signature) that is then embedded into a QR code.

This library conforms to the [SMART Health Cards: Vaccination & Testing Implementation Guide](http://build.fhir.org/ig/dvci/vaccine-credential-ig/branches/main/), and a reference implementation in rails can be found [here](https://github.com/dvci/health_cards).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'health_cards'
```

And then execute:

```
 $ bundle install
```

Or install it yourself as:

```
 $ gem install health_cards
```

## Usage

```ruby
# Create issuer
private_key = HealthCards::Key.generate_key
issuer = HealthCards::Issuer.new(key: private_key)

# Create health card
medical_data = FHIR::Bundle.new # populate with patient data
health_card = issuer.create_health_card(medical_data)

# Issue JWS
jws = issuer.issue_jws(medical_data)

# Create verifier
verifier = HealthCards::Verifier.new

# Verify JWS
verifier.verify(jws) # => true
```

See more usage examples in [USAGE.md](https://github.com/dvci/health_cards/blob/master/lib/USAGE.md). See full documentation in [API.md](https://github.com/dvci/health_cards/blob/master/lib/API.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dvci/health_cards. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dvci/health_cards/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright 2020 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Code of Conduct

Everyone interacting in the HealthCards project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dvci/health_cards/blob/master/CODE_OF_CONDUCT.md).






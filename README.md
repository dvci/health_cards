# HealthCards

![Build](https://github.com/dvci/health_cards/actions/workflows/ruby.yml/badge.svg)

This repository includes a Ruby gem for [SMART Health Cards](https://smarthealth.cards/) **and** a reference implementation for the [SMART Health Cards: Vaccination & Testing Implementation Guide](https://vci.org/ig/vaccination-and-testing). Go to the [Health Card Gem](#health-cards-gem) section to read about the Ruby library or go to the [Reference Implementation](#reference-implementation) section to try a ready-to-use rails application.

## Reference Implementation

The reference implementation is a Ruby on Rails application with Issuer capabilities for creating SMART Health Cards and Verifier capabilities for confirming an individual's vaccination status or laboratory test results.

This Issuer supports the three defined [methods of retrieving a SMART Health Card](https://spec.smarthealth.cards/#user-retrieves-health-cards):

* via a `*.smart-health-card` file
* via a QR code
* via FHIR `$health-card-issue` operation

The Verifier supports scanning QR codes.

### System Requirements
 - Ruby 2.7 (prior versions may work but are not tested)
 - [Bundler](https://bundler.io)
 - [Node.js](https://nodejs.org/en/)
 - [Yarn](https://yarnpkg.com)

### Quick Start

Clone and change directory into the repository:

```bash
git clone https://github.com/dvci/health_cards.git
cd health_cards
```

Setup environment:

`bin/setup`

Run server:

`bin/rails server`

Then go to `http://127.0.0.1:3000` to view the locally running application.


## Health Cards Gem

Health Cards is a Ruby gem that implements [SMART Health Cards](https://smarthealth.cards), a framework for sharing verifiable clinical data with [HL7 FHIR](https://hl7.org/FHIR/) and [JSON Web Signatures (JWS)](https://datatracker.ietf.org/doc/html/rfc7515) which may then be embedded into a QR code, exported to a `*.smart-health-card` file, or returned by a `$health-card-issue` FHIR operation.

This library also natively supports [SMART Health Cards: Vaccination & Testing Implementation Guide](https://vci.org/ig/vaccination-and-testing) specific cards.

### Installation

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

### Documentation

See usage examples in [USAGE.md](https://github.com/dvci/health_cards/blob/main/lib/USAGE.md). 

See full documentation in [API.md](https://github.com/dvci/health_cards/blob/main/lib/API.md).

## Development

Fork or clone this repository, then run `bin/setup` or `bundle install` to install dependencies. Run tests with `rake test`. Access an interactive prompt for experimentation with `bin/console`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dvci/health_cards. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dvci/health_cards/blob/main/CODE_OF_CONDUCT.md).

## License

Copyright 2021 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Code of Conduct

Everyone interacting in the HealthCards project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dvci/health_cards/blob/main/CODE_OF_CONDUCT.md).

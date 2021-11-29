# Changelog

_Note: This changelog is tracking changes related to the `health_cards` library._

## [v1.0.0]
- API Redesign: Old HealthCard class becomes Payload, new HealthCard class used by Issuer and Verifier [\#99](https://github.com/dvci/health_cards/pull/99)
- Updated Allowables to reflect latest Vaccination IG [\#98](https://github.com/dvci/health_cards/pull/98)
- Allow for unfiltered Health Cards [\#93](https://github.com/dvci/health_cards/pull/93)
- More Robust Multi-Mode Support via updated RQRCode gem [\#88](https://github.com/dvci/health_cards/pull/88)
- HealthCard attributes (FHIR Version, Card Types) are inheritable [\#87](https://github.com/dvci/health_cards/pull/87)
- Update README [\#85](https://github.com/dvci/health_cards/pull/85) [\#90](https://github.com/dvci/health_cards/pull/90)
- Added Support for Lab Results in Health Cards [\#72](https://github.com/dvci/health_cards/pull/72)

## [v0.0.2](https://github.com/dvci/health_cards/tree/v0.0.2) (2021-07-09)
- Added `fhir_models` >= 4.0 dependency [\#69](https://github.com/dvci/health_cards/pull/69)
- Added native QR Code generation [\#62](https://github.com/dvci/health_cards/pull/62)
- Updated FHIR Bundle minification [\#60](https://github.com/dvci/health_cards/pull/60)
- Updated error handling [\#63](https://github.com/dvci/health_cards/pull/63)
- Updated allowed/disallowed attributes implemenation [\#67](https://github.com/dvci/health_cards/pull/67)
- Updated key resolution failure error handling [\#74](https://github.com/dvci/health_cards/pull/74)
- Updated Bundle minification to use `each_element` [\#75](https://github.com/dvci/health_cards/pull/75)
- Updated README [\#70](https://github.com/dvci/health_cards/pull/70)
- Removed `json-minify` dependency [\#69](https://github.com/dvci/health_cards/pull/69)
- Fixed `COVIDHealthCard` VC Type [\#56](https://github.com/dvci/health_cards/pull/56)

## v0.0.1 (2021-05-14)
 - Initial `health_cards` release
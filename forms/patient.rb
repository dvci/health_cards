require 'fhir_models'
require 'app.rb'

patient = FHIR::Patient.new(
  'name' => [{ 'given' => given}]
#   'category' => {
#     'coding' => [{ 'system' => 'http://hl7.org/fhir/observation-category', 'code' => 'vital-signs' }]
#   },
#   'subject' => { 'reference' => 'Patient/example' },
#   'context' => { 'reference' => 'Encounter/example' }
)
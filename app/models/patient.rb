# frozen_string_literal: true

# Patient model acts as a shim around a FHIR JSON patient blob in order to interact with
# form builder and enable us to save the JSON into a database
class Patient < ApplicationRecord
  attribute :given, :string
  attribute :family, :string
  attribute :gender, :string
  attribute :phone, :string
  attribute :email, :string
  attribute :birth_date, :date

  FHIR_DEFINITION = FHIR::Definitions.resource_definition('Patient')
  GENDERS = FHIR::Patient::METADATA['gender']['valid_codes']['http://hl7.org/fhir/administrative-gender']

  validates :gender, inclusion: { in: GENDERS, allow_nil: true }
  validate do
    FHIR_DEFINITION.errors.each { |e| errors.add(:base, e) } unless FHIR_DEFINITION.validates_resource?(fhir_patient)
  end

  before_validation do
    self.json = new_from_attributes.to_json
  end

  after_find do
    name = fhir_patient.name.first
    if name
      self.given  = name.given.first
      self.family = name.family
    end
    self.gender = fhir_patient.gender
    self.email  = fhir_patient.telecom.find { |t|  t.system == 'email' }.value
    self.phone  = fhir_patient.telecom.find { |t|  t.system == 'phone' }.value
    self.birth_date = fhir_patient.birthDate
  end

  def full_name
    [given, family].join(' ') if given || family
  end

  private

  def fhir_patient
    return @patient if @patient && !has_changes_to_save?

    @patient = FHIR.from_contents(json)
  end

  def new_from_attributes
    FHIR::Patient.new(
      name: [{ given: [given], family: family }],
      gender: gender,
      telecom: [{ system: 'phone', value: phone },
                { system: 'email', value: email }],
      birthDate: birth_date
    )
  end
end

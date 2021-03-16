# frozen_string_literal: true

# require 'concerns/fhir_json_storage'
require 'serializers/fhir'

# Patient model to map our input form to FHIR
class Patient < ApplicationRecord

  attribute :given, :string
  attribute :family, :string
  attribute :gender, :string
  attribute :birth_date, :date

  serialize :json, FHIR::Patient

  has_many :immunizations, dependent: :destroy

  GENDERS = FHIR::Patient::METADATA['gender']['valid_codes']['http://hl7.org/fhir/administrative-gender']

  validates :given, presence: true
  validates :gender, inclusion: { in: GENDERS, allow_nil: true }

  def full_name
    [given, family].join(' ') if given || family
  end

  def given
    first_name[:given].try(:first)
  end

  def given=(_given)
    json.name = [{given: [_given]}]
    super(_given)
  end

  def family
    first_name[:family]
  end

  def family=(_family)
    first_name[:family] = _family
    super(_family)
  end

  def gender
    json.gender
  end

  def gender=(_gender)
    json.gender = _gender
    super(_gender)
  end

  def birth_date
    json.birthDate
  end

  def birth_date=(_birth_date)
    json.birthDate = _birth_date
    super(_birth_date)
  end

  private

  def first_name
    json.name ||= name
    json.name[0] ||= {}
  end

end

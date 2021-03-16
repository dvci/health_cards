# frozen_string_literal: true

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

  def to_bundle
    entries = [self.json] + self.immunizations.map(&:json)
    FHIR::Bundle.new(type: 'collection', entry: entries)
  end

  # Overriden getters/setters to support FHIR JSON

  def given
    first_name[:given].try(:first)
  end
FHIR::Bundle
  def given=(giv)
    json.name = [{ given: [giv] }]
    super(giv)
  end

  def family
    first_name[:family]
  end

  def family=(fam)
    first_name[:family] = fam
    super(fam)
  end

  delegate :gender, to: :json

  def gender=(gen)
    json.gender = gen
    super(gen)
  end

  def birth_date
    json.birthDate
  end

  def birth_date=(bdt)
    json.birthDate = bdt
    super(bdt)
  end

  private

  def first_name
    json.name ||= name
    json.name[0] ||= {}
  end
end

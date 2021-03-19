# frozen_string_literal: true

require 'serializers/fhir_serializer'

# Patient model to map our input form to FHIR
class Patient < FHIRRecord
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
    entries = [json] + immunizations.map(&:json)
    FHIR::Bundle.new(type: 'collection', entry: entries)
  end

  # Overriden getters/setters to support FHIR JSON

  def given
    first_name.given.try(:first)
  end

  def given=(giv)
    first_name.given = [giv]
    super(giv)
  end

  delegate :family, to: :first_name

  def family=(fam)
    first_name.family = fam.presence
    super(fam)
  end

  delegate :gender, to: :json

  def gender=(gen)
    json.gender = gen
    super(gen)
  end

  def birth_date
    from_fhir_time(json.birthDate)
  end

  def birth_date=(bdt)
    super(bdt)
    json.birthDate = to_fhir_time(attributes['birth_date'])
    attributes['birth_date']
  end

  private

  def first_name
    json.name << FHIR::HumanName.new if json.name.empty?
    json.name[0]
  end
end

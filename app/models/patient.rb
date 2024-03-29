# frozen_string_literal: true

require 'serializers/fhir_serializer'

# Patient model to map our input form to FHIR
class Patient < FHIRRecord
  attribute :given, :string
  attribute :family, :string
  attribute :gender, :string
  attribute :birth_date, :date
  attribute :phone, :string
  attribute :email, :string
  attribute :street_line1, :string
  attribute :street_line2, :string
  attribute :city, :string
  attribute :state, :string
  attribute :zip_code, :string

  serialize :json, FHIR::Patient

  has_many :immunizations, dependent: :destroy
  has_many :lab_results, dependent: :destroy

  GENDERS = FHIR::Patient::METADATA['gender']['valid_codes']['http://hl7.org/fhir/administrative-gender']

  validate :name_attribute_is_populated
  validates :gender, inclusion: { in: GENDERS, allow_nil: true }

  def full_name
    [given, family].join(' ') if given || family
  end

  # Overriden getters/setters to support FHIR JSON

  def given
    first_name.given.try(:first) || first_name.text
  end

  def given=(giv)
    first_name.given = giv.present? ? [giv] : nil
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

  def street_line1
    address.line[0]
  end

  def street_line1=(st1)
    address.line[0] = st1.presence
    super(st1)
  end

  def street_line2
    address.line[1]
  end

  def street_line2=(st2)
    address.line[1] = st2.presence
    super(st2)
  end

  delegate :city, to: :address

  def city=(cit)
    address.city = cit.presence
    super(cit)
  end

  delegate :state, to: :address

  def state=(sta)
    address.state = sta.presence
    super sta
  end

  def zip_code
    address.postalCode
  end

  def zip_code=(zip)
    address.postalCode = zip.presence
    super(zip)
  end

  def phone
    phone_contact.value
  end

  def phone=(pho)
    phone_contact.value = pho.presence
    super(pho)
  end

  def email
    email_contact.value
  end

  def email=(ema)
    email_contact.value = ema.presence
    super(ema)
  end

  def to_bundle(base_url)
    bundle = FHIR::Bundle.new(type: 'collection')
    patient_url = "#{base_url}/Patient/#{json.id}"
    bundle.entry[0] = FHIR::Bundle::Entry.new(fullUrl: patient_url, resource: json)
    immunizations.each do |imm|
      bundle.entry << FHIR::Bundle::Entry.new(fullUrl: "#{base_url}/Immunization/#{imm.json.id}", resource: imm.json)
    end
    lab_results.each do |lr|
      bundle.entry << FHIR::Bundle::Entry.new(fullUrl: "#{base_url}/Observation/#{lr.json.id}", resource: lr.json)
    end
    bundle
  end

  private

  def name_attribute_is_populated
    errors.add(:base, 'Either given or family name must not be blank') unless given || family
  end

  def phone_contact
    setup_contact('phone')
  end

  def email_contact
    setup_contact('email')
  end

  def setup_contact(use)
    tele = json.telecom.find { |tel| tel.system == use }
    unless tele
      json.telecom << FHIR::ContactPoint.new(system: use)
      tele = json.telecom.last
    end
    tele
  end

  def address
    home_address = json.address.find { |add| add.use == 'home' }
    unless home_address
      json.address << FHIR::Address.new(use: 'home')
      home_address = json.address.last
    end
    home_address
  end

  def first_name
    json.name << FHIR::HumanName.new if json.name.empty?
    json.name[0]
  end
end

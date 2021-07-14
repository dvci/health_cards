# frozen_string_literal: true

module SearchHelper
  # This helper integrates the app/views/search/form.html.erb input fields with QBP client query parameters
  # Omits the following QBP parameters from query:
  # - query[:address][:address_type]
  # - query[:multiple_birth_indicator]
  # - query[:birth_order]
  # - query[:client_last_updated_date]
  # - query[:client_last_updated_facility]

  FHIR_TO_HL7_SEX = { 'male' => 'M', 'female' => 'F', 'other' => 'U', 'unknown' => 'U' }.freeze

  def sanitize_input(action_params)
    action_params.require(:patient).permit([
                                             :given,
                                             :family,
                                             :second,
                                             :suffix,
                                             :birth_date,
                                             :gender,
                                             :phone,
                                             :list_id,
                                             :assigning_authority,
                                             :identifier_type_code,
                                             :mother_maiden_given_name,
                                             :mother_maiden_family_name,
                                             :street_line1,
                                             :street_line2,
                                             :city,
                                             :state,
                                             :zip_code
                                           ])
  end

  def transform_hash(action_params)
    h = action_params.to_hash
    h.transform_keys!(&:to_sym)
    h.transform_values!(&:strip)
    h.transform_values! { |v| v.empty? ? nil : v }
    h
  end

  def format_patient_name(hash)
    hash.slice(:given, :family, :second, :suffix)
  end

  def format_patient_list(hash)
    hash.slice(:assigning_authority, :identifier_type_code).merge!({ id: hash[:list_id] })
  end

  def format_dob(hash)
    hash[:birth_date].split('/').reverse.join if hash[:birth_date]
  end

  def format_phone_number(hash)
    { area_code: hash[:phone].split('-')[0], local_number: hash[:phone].split('-')[1..3].join } if hash[:phone]
  end

  def format_street_address(hash)
    if hash[:street_line2] && hash[:street_line1]
      "#{hash[:street_line1]}, #{hash[:street_line2]}"
    else
      hash[:street_line1]
      hash[:street_line1]
    end
  end

  def format_address(hash)
    hash.slice(:city, :state).merge!({ zip: hash[:zip_code], street: format_street_address(hash) })
  end

  def build_query(hash)
    {
      patient_name: format_patient_name(hash),
      patient_dob: format_dob(hash),
      patient_list: format_patient_list(hash),
      mother_maiden_name: { family: hash[:mother_maiden_family_name], given: hash[:mother_maiden_given_name] },
      sex: FHIR_TO_HL7_SEX[hash[:gender]],
      address: format_address(hash),
      phone: format_phone_number(hash)
    }
  end
end

# frozen_string_literal: true

# QPD Segment
class HL7::Message::Segment::QPD < HL7::Message::Segment # rubocop:disable Style/ClassAndModuleChildren
  weight 1
  add_field :message_query_name
  add_field :query_tag
  add_field :patient_id_list
  add_field :patient_name
  add_field :mother_maiden_name
  add_field :patient_dob do |value|
    convert_to_ts(value)
  end
  add_field :admin_sex do |sex|
    unless /^[FMOUANC]$/.match(sex) || sex.nil? || sex == ''
      raise HL7::InvalidDataError, 'bad administrative sex value (not F|M|O|U|A|N|C)'
    end

    sex ||= ''
    sex
  end
  add_field :address
  add_field :phone_home
  add_field :multi_birth
  add_field :birth_order
  add_field :last_update_date do |value|
    convert_to_ts(value)
  end
  add_field :last_update_facility
end

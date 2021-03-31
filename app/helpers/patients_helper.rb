# frozen_string_literal: true

module PatientsHelper

  def show_address(patient)
    [patient.street_line1, patient.street_line2, patient.city, patient.state, patient.zip_code].compact.join(', ')
  end

  def fake_patient_params
    gender = Patient::GENDERS.sample
    phone = Faker::PhoneNumber.phone_number
    email = Faker::Internet.email
    street_line1 = Faker::Address.street_address
    city = Faker::Address.city
    state = Faker::Address.state_abbr
    zip_code = Faker::Address.zip_code
    birth_date =  Faker::Date.birthday(min_age: 16, max_age: 100)
    street_line2 = Faker::Address.secondary_address
    given = case gender
            when 'male'
              Faker::Name.male_first_name
            when 'female'
              Faker::Name.female_first_name
            else
              Faker::Name.first_name
            end
    { patient: { given: given, family: Faker::Name.last_name, gender: gender,
                 birth_date: birth_date, phone: phone, email: email, street_line1: street_line1, street_line2: street_line2, city: city, state: state, zip_code: zip_code}}
  end
end

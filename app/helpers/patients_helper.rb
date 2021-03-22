# frozen_string_literal: true

module PatientsHelper
  def fake_patient_params
    gender = Patient::GENDERS.sample
    given = case gender
            when 'male'
              Faker::Name.male_first_name
            when 'female'
              Faker::Name.female_first_name
            else
              Faker::Name.first_name
            end
    { patient: { given: given, family: Faker::Name.last_name, gender: gender,
                 birth_date: Faker::Date.birthday(min_age: 16, max_age: 100) } }
  end
end

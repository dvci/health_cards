# frozen_string_literal: true

module PatientsHelper

    def fake_patient_params
        {:given => Faker::Name.unique.first_name, :family => Faker::Name.unique.last_name, :gender => Faker::Gender, :birth_date => "01/01/1991"}
    end 
end

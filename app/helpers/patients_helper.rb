# frozen_string_literal: true

module PatientsHelper
  def show_address(patient)
    [patient.street_line1, patient.street_line2, patient.city, patient.state, patient.zip_code].compact.join(', ')
  end

    def fake_patient_params
<<<<<<< Updated upstream
        {:given => Faker::Name.unique.first_name, :family => Faker::Name.unique.last_name, :gender => Faker::Gender, :birth_date => "01/01/1991"}
=======
        {:given => Faker::Name.unique.first_name, :family => Faker::Name.unique.last_name, :gender => Faker::Gender, :phone => Faker::PhoneNumber.phone_number, :email => "example@gmail.com", :birth_date => "01/01/1991"}
>>>>>>> Stashed changes
    end 
end

# frozen_string_literal: true

module PatientsHelper
  def show_address(patient)
    [patient.street_line1, patient.street_line2, patient.city, patient.state, patient.zip_code].compact.join(', ')
  end
end

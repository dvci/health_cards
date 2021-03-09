# frozen_string_literal: true

# patient_manager_class - retrieve patient
require 'singleton'
require 'securerandom'

class PatientManager
    include Singleton

    class << self

        def patients
            @patients ||= {}
        end 

        def get_patient_by_id(patient_id)
            return patients[patient_id]
        end 

        def add_patient(patient)
            id = SecureRandom.uuid
            patients[id] = patient
        end 
    end 

  end
# frozen_string_literal: true

json.array! @patients, partial: 'patients/patient', as: :patient

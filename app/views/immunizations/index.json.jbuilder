# frozen_string_literal: true

json.array! @immunizations, partial: 'immunizations/immunization', as: :immunization

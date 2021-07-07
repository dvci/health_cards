# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Vaccine.find_or_create_by(code: '207') do |vaccine|
  vaccine.name = 'Moderna COVID-19 Vaccine'
  vaccine.doses_required = 2
end
Vaccine.find_or_create_by(code: '208') do |vaccine|
  vaccine.name = 'Pfizer COVID-19 Vaccine'
  vaccine.doses_required = 2
end
Vaccine.find_or_create_by(code: '212') do |vaccine|
  vaccine.name = 'Janssen COVID-19 Vaccine'
  vaccine.doses_required = 1
end


#get valueset object as json and create a new valueset injected as a new object
#ValueSet.get_code_from_valueset(valueset)
#read the json and stick into the json attribute (under lab_codes)
# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Vaccine.create(name: 'Moderna COVID-19 Vaccine',
	       code: '207',
	       doses_required: 2)
Vaccine.create(name: 'Pfizer COVID-19 Vaccine',
	       code: '208',
	       doses_required: 2)
Vaccine.create(name: 'Janssen COVID-19 Vaccine',
	       code: '212',
	       doses_required: 1)

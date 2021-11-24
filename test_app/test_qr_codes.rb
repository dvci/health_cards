#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'health_cards'

qr_inspect = lambda do |qr|
  qr.chunks.each do |ch|
    puts "Chunk #{ch.ordinal}\n=======\n" if qr.chunks.length > 1
    puts "Version: #{ch.qr_code.version}"
    puts "ECL: #{ch.qr_code.error_correction_level}"
  end
end

qr = HealthCards::QRCodes.new(ARGV)
puts "\n--------"
puts 'QR Codes'
puts '--------'
qr_inspect.call(qr)

jws = qr.to_jws
hc = HealthCards::COVIDImmunizationPayload.from_jws(jws)

puts "\n------"
puts 'Bundle'
puts '------'
hc.bundle.entry.map(&:resource).each do |e|
  print "#{e.resourceType}: "
  case e
  when FHIR::Patient
    puts e.name.map { |n| "#{n.given.join(' ')} #{n.family}" }.join(' / ')
  when FHIR::Immunization
    puts "Code: #{e.vaccineCode&.coding&.map(&:code)&.join(', ')} Date: #{e.occurrence} " \
         "Performer: #{e.performer&.map(&:actor)&.map(&:display)&.join(', ')}"
  when FHIR::Observation
    puts "Code: #{e.code&.coding&.map(&:code)&.join(', ')} Date: #{e.effectiveDateTime} " \
         "Result: #{e.valueCodeableConcept&.map(&:code)&.join(', ')}"
  else
    puts 'NOT ALLOWED'
  end
end

puts "\n--------"
puts 'QR Codes (Re-encoded)'
puts '--------'

qr2 = HealthCards::QRCodes.from_jws(jws)
qr_inspect.call(qr2)

# Enable if you want to export the QR code re-encoded
# qr2.chunks.each do |ch|
#   filename = "re-encoded qr-code-#{ch.ordinal}.png"
#   ch.image.save(filename)
#   puts "Saved re-encoded QR Code as #{filename}"
# end

puts

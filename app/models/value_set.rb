# frozen_string_literal: true

class ValueSet
  attr_reader :codes

  def initialize(file)
    @codes = FHIR.from_contents(File.read(file)).compose.include.map do |compose|
      compose.concept.map do |concept|
        FHIR::Coding.new(system: compose.system, code: concept.code, display: concept.display)
      end
    end.flatten
  end

  RESULTS = ValueSet.new('db/lab_codes/ValueSet-qualitative-lab-result-findings.json').freeze
  LAB_CODES = ValueSet.new('db/lab_codes/ValueSet-2.16.840.1.113762.1.4.1114.9.json').freeze

  def find_code(code_string)
    codes.find { |code| code.code == code_string }
  end

  def systems
    codes.map(&:system).uniq
  end

  def code_values
    codes.map(&:code)
  end
end

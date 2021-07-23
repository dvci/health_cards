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

  def find_by_code(code_string)
    codes.find { |code| code.code == code_string}
  end

  def systems
    codes.map { |code| code.system }.uniq
  end
    # def self.get_info_from_valuesete
    #     # value_set_inform_arr = []
    #     # value_set_json.compose.include.each do |inform|
    #     #     code_system = inform.system #= value_set['compose']['include'][0]['system']
    #     #     temp_arr = []
    #     #     inform.concept.each do |code_display_info|
    #     #         value_set_code = code_display_info.code 
    #     #         display = code_display_info.display 
    #     #         temp_arr.append(value_set_code, display)
    #     #     end
    #     #     value_set_inform_arr.append(code_system, temp_arr)
    #     # end
    #     # return value_set_inform_arr

    #     @@value_set_json.compose.include
    #     # value_set_json.compose.include.each do |each_concept|
    #     #     code_system = each_concept.system
    #     #     temp_arr = []
    #     #     each_concept.concept.each do |info|
    #     #         value_set_code = info.code
    #     #         display = info.display
    #     #     end 
    #     # end 


    #     # {
    #     #     "http://snomed.info/sct" => [[value_set_json['compose']['include'][0]['concept'][0]["code"], value_set_json['compose']['include'][0]['concept'][0]["display"]]],
    #     #     "http://loinc.org" => [[value_set_json['compose']['include'][0]['concept'][0]["code"], value_set_json['compose']['include'][0]['concept'][0]["display"]]]
    #     # } 
        
    # end

    # #RESULTS = get_info_from_valueset(value_set_json)

    # @@value_set_covid_json = 
    # def self.get_covid_codes_valueset
    #     @@value_set_covid_json.compose.include
    # end 

end

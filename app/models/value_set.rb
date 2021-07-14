class ValueSet < FHIRRecord
    attribute :code
    attribute :code_system
    attribute :display

serialize :json, FHIR::ValueSet 

#get the code and display information from the valueset 
#return list of code and display objects
def self.get_info_from_valueset (value_set)
    value_set_code = value_set['compose']['include'][0]['concept'][0]["code"]
    display = value_set['compose']['include'][0]['concept'][0]["display"]
    code_system = value_set_code = value_set['compose']['include'][0]['system']

    return [code_system, value_set_code, display]
end

end

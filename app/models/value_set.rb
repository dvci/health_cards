class ValueSet < FHIRRecord
    attribute :value_set_code
    attribute :display

serialize :json, FHIR::ValueSet

#get the code and display information from the valueset 
#return list of code and display objects
def self.get_info_from_valueset (value_set)
    value_set_code = value_set['compose']['include'][0]['concept'].code
    display = value_set['compose']['include'][0]['concept'].display
    return [value_set_code, display]
end

end

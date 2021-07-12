class ValueSet < FHIRRecord
    attribute :valueset_code
    attribute :display

serialize :json, FHIR::ValueSet

#get the code and display information from the valueset 
#return list of code and display objects
def get_info_from_valueset (valueset)
    valueset_code = valueset['compose']['include'][0]['concept'].code
    display = valueset['compose']['include'][0]['concept'].display
    return [valueset_code, display]
end

end

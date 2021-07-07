# frozen_string_literal: true

require "savon"
require "ruby-hl7"
require 'faraday'
require_relative 'qpd'

module HealthCards
  module QBPClient
    extend self

    # Create a HealthCard from a compressed payload
    # @param patient_info [Hash] Patient Demographic info sent from the IIS Consumer Portal
    # @param credentials [Hash] User Id, Password, and Facility Id for the IIS Sandbox login
    # @return [Hash]
        # response_status: [Symbol] The status 
        # response: [String] The HL7 V2 Response message from the IIS-Sandbox, represented as a string
    def query(patient_info,
              sandbox_credentials = { username: Rails.application.config.username,
                             password: Rails.application.config.password,
                             facilityID: Rails.application.config.facilityID 
                            }
            )

        unless validCredentials?(sandbox_credentials)
            raise HealthCards::InvalidSandboxCredentialsError
        end

        puts "PATIENT HASH: "
        puts patient_info

        service_def = "lib/assets/service.wsdl"
        puts "WSDL #{service_def}"
        
        client = Savon.client(wsdl: service_def, 
            endpoint: "http://localhost:8081/iis-sandbox/soap", 
            pretty_print_xml: true)
        puts client.operations
        
        response = client.call(:connectivity_test) do
            message echoBack: "?"
        end
        
        puts response
        
        raw_input = open( "lib/assets/qbp.hl7" ).readlines
        msg_input = HL7::Message.new( raw_input )
        uid = rand(10000000000).to_s
        
        msh = msg_input[:MSH]
        msh.time = Time.now
        msh.message_control_id = uid
        qpd = msg_input[:QPD]
        
        qpd.query_tag = uid
        
        patient_id_list = HL7::MessageParser.split_by_delimiter(qpd.patient_id_list, msg_input.item_delim)
        patient_id_list[1] = patient_info[:patient_list][:id] # ID
        patient_id_list[4] = patient_info[:patient_list][:assigning_authority] # assigning authority
        patient_id_list[5] = patient_info[:patient_list][:identifier_type_code] # identifier type code
        qpd.patient_id_list = patient_id_list.join(msg_input.item_delim)
        
        patient_name = HL7::MessageParser.split_by_delimiter(qpd.patient_name, msg_input.item_delim)
        patient_name[0] = patient_info[:patient_name][:family_name] # family name
        patient_name[1] = patient_info[:patient_name][:given_name] # given name
        patient_name[2] = patient_info[:patient_name][:second_or_further_names] # second name
        patient_name[3] = patient_info[:patient_name][:suffix]# suffix name
        qpd.patient_name = patient_name.join(msg_input.item_delim)
        
        mother_maiden_name = HL7::MessageParser.split_by_delimiter(qpd.mother_maiden_name, msg_input.item_delim)
        mother_maiden_name[0] = patient_info[:mothers_maiden_name][:family_name] # family name
        mother_maiden_name[1] = patient_info[:mothers_maiden_name][:given_name] # given name
        mother_maiden_name[6] = patient_info[:mothers_maiden_name][:name_type_code] # name type code, M = Maiden Name
        qpd.mother_maiden_name = mother_maiden_name.join(msg_input.item_delim)
        
        qpd.patient_dob = patient_info[:patient_dob]
        
        qpd.admin_sex = patient_info[:admin_sex]
        
        address = HL7::MessageParser.split_by_delimiter(qpd.address, msg_input.item_delim)
        address[0] = patient_info[:address][:street] # street address
        address[2] = patient_info[:address][:city] # city
        address[3] = patient_info[:address][:state] # state
        address[4] = patient_info[:address][:zip] # zip
        address[6] = patient_info[:address][:address_type] # address type
        qpd.address = address.join(msg_input.item_delim)
        
        phone_home = HL7::MessageParser.split_by_delimiter(qpd.phone_home, msg_input.item_delim)
        phone_home[5] = patient_info[:phone][:area_code] # area code
        phone_home[6] = patient_info[:phone][:local_number] # local number
        qpd.phone_home = phone_home.join(msg_input.item_delim)
        
        # Upload Patient
        # upload_raw_input = open( "lib/assets/vxu.hl7" ).readlines
        # upload_msg_input = HL7::Message.new( upload_raw_input )

        puts "REQUEST:"
        puts msg_input.to_hl7
        
        # Make this it's own function?
        response = client.call(:submit_single_message) do
            message **sandbox_credentials, hl7Message: msg_input
        end
        
        msg_output = HL7::Message.new(response.body[:submit_single_message_response][:return])

        # getResponseStatus(msg_output)

        puts "RESPONSE:"
        puts msg_output.to_hl7 # Printing response for testing purposes



        return msg_output.to_hl7
    end
        
    # Translate relevant info from V2 Response message into a FHIR Bundle
    # @param v2_response [String] V2 message returned from the IIS-Sandbox 
    # @return [String] FHIR Bundle representation of the V2 message
    def tranlate(v2_response)
        fhir_response = Faraday.post('http://localhost:3000/api/v0.1.0/convert/text',
            v2_response,
            "Content-Type" => "text/plain")
        puts "FHIR:"

        puts fhir_response.body # Printing response for testing purposes

        return fhir_response.body
    end

    # TODO: Add a function to upload a patient to an IIS

    private

    def getResponseStatus(msg_response)
        # Get QAK.2
    end

    def validCredentials?(credentials)
        credentials.each do |k,v|
            unless (v.is_a? String)
                return false
            end
        end
        credentials.keys.sort == [:username, :password, :facilityID].sort 
    end

  end
end


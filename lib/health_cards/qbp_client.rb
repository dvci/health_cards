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
                             facilityID: Rails.application.config.facilityID }
            )

        unless validCredentials?(sandbox_credentials)
            raise InvalidSandboxCredentialsError
        end

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
        patient_id_list[1] = 'J19X5' # ID
        patient_id_list[4] = 'AIRA-TEST' # assigning authority
        patient_id_list[5] = 'MR' # identifier type code
        qpd.patient_id_list = patient_id_list.join(msg_input.item_delim)
        
        patient_name = HL7::MessageParser.split_by_delimiter(qpd.patient_name, msg_input.item_delim)
        patient_name[0] = 'WeilAIRA' # family name
        patient_name[1] = 'BethesdaAIRA' # given name
        patient_name[2] = 'Delvene' # second name
        patient_name[3] = '' # suffix name
        qpd.patient_name = patient_name.join(msg_input.item_delim)
        
        mother_maiden_name = HL7::MessageParser.split_by_delimiter(qpd.mother_maiden_name, msg_input.item_delim)
        mother_maiden_name[0] = 'WeilAIRA' # family name
        mother_maiden_name[1] = 'BethesdaAIRA' # given name
        mother_maiden_name[6] = 'M' # name type code, M = Maiden Name
        qpd.mother_maiden_name = mother_maiden_name.join(msg_input.item_delim)
        
        qpd.patient_dob = "20170610"
        
        qpd.admin_sex = "F"
        
        address = HL7::MessageParser.split_by_delimiter(qpd.address, msg_input.item_delim)
        address[0] = '1113 Wollands Kroon Ave' # street address
        address[2] = 'Hamburg' # city
        address[3] = 'MI' # state
        address[4] = '48139' # zip
        address[6] = 'P' # address type
        qpd.address = address.join(msg_input.item_delim)
        
        phone_home = HL7::MessageParser.split_by_delimiter(qpd.phone_home, msg_input.item_delim)
        phone_home[5] = '810' # area code
        phone_home[6] = '2499010' # local number
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
        
    # Create a HealthCard from a compressed payload
    # @param payload [String]
    # @return [HealthCards::HealthCard]
    def tranlate(v2_response)
        fhir_response = Faraday.post('http://localhost:3000/api/v0.1.0/convert/text',
            v2_response,
            "Content-Type" => "text/plain")
        puts "FHIR:"

        puts fhir_response.body # Printing response for testing purposes

        return fhir_response.body
    end

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


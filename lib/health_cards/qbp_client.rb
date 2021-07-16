# frozen_string_literal: true

require 'savon'
require 'ruby-hl7'
require 'faraday'
require_relative 'qpd'

module HealthCards
  # Send, receive, and translate HL7 V2 messages from the QBP client of the IIS sandbox
  module QBPClient
    extend self
    # Query a patient's Immunization history from the IIS Sandbox
    # @param patient_info [Hash] Patient Demographic info sent from the IIS Consumer Portal
    # @param credentials [Hash] User Id, Password, and Facility Id for the IIS Sandbox login
    # @return [Hash]
    # response_status: [Symbol] The status
    # response: [String] The HL7 V2 Response message from the IIS-Sandbox, represented as a string
    def query(patient_info,
              sandbox_credentials = { username: Rails.application.config.username,
                                      password: Rails.application.config.password,
                                      facilityID: Rails.application.config.facilityID })
      # Rubocop: This method needs to be shorter

      raise HealthCards::InvalidSandboxCredentialsError unless valid_credentials?(sandbox_credentials)

      service_def = 'lib/assets/service.wsdl'
      # TODO: Set up with MITRE hosted VCI VM
      client = Savon.client(wsdl: service_def,
                            # endpoint: 'http://localhost:8081/iis-sandbox/soap',
                            endpoint: 'http://vci.mitre.org:8081/iis-sandbox/soap',
                            pretty_print_xml: true)

      # Check if client is configured properly
      raise HealthCards::OperationNotSupportedError unless client.operations.include?(:submit_single_message)
      check_client_connectivity(client) if client.operations.include?(:connectivity_test)

      # Put this in it's own function: build_hl7_message()
      raw_input = open('lib/assets/qbp.hl7').readlines
      msg_input = HL7::Message.new(raw_input)
      uid = rand(10_000_000_000).to_s

      msh = msg_input[:MSH]
      msh.time = Time.zone.now
      msh.message_control_id = uid
      qpd = msg_input[:QPD]

      qpd.query_tag = uid

      # To Do -> condense by making a variable. Default to empty string
      patient_id_list = HL7::MessageParser.split_by_delimiter(qpd.patient_id_list, msg_input.item_delim)
      patient_id_list[1] = patient_info[:patient_list][:id] # ID
      patient_id_list[4] = patient_info[:patient_list][:assigning_authority] # assigning authority
      patient_id_list[5] = patient_info[:patient_list][:identifier_type_code] # identifier type code
      qpd.patient_id_list = patient_id_list.join(msg_input.item_delim)

      patient_name = HL7::MessageParser.split_by_delimiter(qpd.patient_name, msg_input.item_delim)
      patient_name[0] = patient_info[:patient_name][:family_name] # family name
      patient_name[1] = patient_info[:patient_name][:given_name] # given name
      patient_name[2] = patient_info[:patient_name][:second_or_further_names] # second name
      patient_name[3] = patient_info[:patient_name][:suffix] # suffix name
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


      # Make this it's own function?
      response = client.call(:submit_single_message) do
        message(**sandbox_credentials, hl7Message: msg_input)
      end

      # TODO: Check for SOAP Faults
      # TODO: Check for Response Error Cases

      raw_response_message = response.body[:submit_single_message_response][:return]
      response_segments = raw_response_message.to_s.split("\n")
      response_message = HL7::Message.new(response_segments)
      check_response_profile_errors(response_message)
      return response_message

      # return {response: msg_output.to_hl7, status: get_response_status(msg_output)}
    end

    def upload_patient(patient_path)
      # Define client
      service_def = 'lib/assets/service.wsdl'
      client = Savon.client(wsdl: service_def,
                            # endpoint: 'http://localhost:8081/iis-sandbox/soap',
                            endpoint: 'http://vci.mitre.org:8081/iis-sandbox/soap',
                            pretty_print_xml: true)
      # Upload Patient from Fixture
      upload_raw_input = open(patient_path).readlines
      upload_msg_input = HL7::Message.new( upload_raw_input )
      response = client.call(:submit_single_message) do
        message({username: Rails.application.config.username,
                password: Rails.application.config.password,
                facilityID: Rails.application.config.facilityID,
                hl7Message: upload_msg_input})
      end
    end



    # Translate relevant info from V2 Response message into a FHIR Bundle
    # @param v2_response [String] V2 message returned from the IIS-Sandbox
    # @return [String] FHIR Bundle representation of the V2 message
    def translate(v2_response)
      # TODO: Set up with Hosted VM
      fhir_response = Faraday.post('http://vci.mitre.org:3000/api/v0.1.0/convert/text',
                                   v2_response.to_hl7,
                                   'Content-Type' => 'text/plain')
      fhir_response.body
    end

    # Methods That Parse HL7 V2 Message
    # Get QAK.2
    def get_response_status(msg_response)
      msg_response[:QAK][2].to_sym
    end

    def check_client_connectivity(client)
      response = client.call(:connectivity_test) do
        message echoBack: '?'
      end
      conncectivity_response = response.body[:connectivity_test_response][:return]
      throw HealthCards::BadClientConnectionError unless conncectivity_response == 'End-point is ready. Echoing: ?'
    end

    # TODO: Check Response Profile Errors
    def check_response_profile_errors(msg_response)
      profile = msg_response[:MSH][20][0..2].to_sym
      case profile
      when :Z32
        handle_Z32_errors(msg_response)
      when :Z31
        handle_Z31_errors(msg_response)
      when :Z33
        handle_Z31_errors(msg_response)
      else
        return nil
      end
    end
    

    private

    def valid_credentials?(credentials)
      credentials.each do |_k, v|
        return false unless v.is_a? String
      end
      credentials.keys.sort == [:username, :password, :facilityID].sort
    end

    # Methods to Handle Profile Specific Errors

    # PROFILE Z32 RESPONSE PROFILE – RETURN COMPLETE IMMUNIZATION HISTORY
    def handle_Z32_errors(msg)
      # TODO: Handle RSP K11 Z32 test cases
      return nil
    end

    # PROFILE Z31 -- RETURN A LIST OF CANDIDATES PROFILE
    def handle_Z31_errors(msg)
      # TODO: Handle RSP K11 Z31 test cases
      return nil
    end

    # PROFILE Z33 --RETURN AN ACKNOWLEDGEMENT WITH NO PERSON RECORDS (ERRORS)
    def handle_Z33_errors(msg)
      # TODO: Handle RSP K11 Z323 test cases
      return nil
    end 


  end
end

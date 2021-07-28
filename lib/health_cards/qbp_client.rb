# frozen_string_literal: true

require 'savon'
require 'ruby-hl7'
require 'faraday'
require_relative 'qpd'

module HealthCards
  # Send, receive, and translate HL7 V2 messages from the QBP client of the IIS sandbox
  module QBPClient # rubocop:disable Metrics/ModuleLength # Disabling since module will be ported and refactored
    extend self
    # Query a patient's Immunization history from the IIS Sandbox
    # @param patient_info [Hash] Patient demographic info sent from the IIS Consumer Portal
    # @param credentials [Hash] (optional) User Id, Password, and Facility Id for the IIS Sandbox login
    # @return [HL7::Message] The HL7 V2 Response message from the IIS-Sandbox
    def query(patient_info,
              sandbox_credentials = { username: Rails.application.config.username,
                                      password: Rails.application.config.password,
                                      facilityID: Rails.application.config.facilityID })
      raise HealthCards::InvalidSandboxCredentialsError unless valid_credentials?(sandbox_credentials)

      service_def = 'lib/assets/service.wsdl'
      client = Savon.client(wsdl: service_def,
                            endpoint: "#{Rails.application.config.iisSandboxHost}/iis-sandbox/soap",
                            pretty_print_xml: true)
      # Check if client is configured properly
      raise HealthCards::OperationNotSupportedError unless client.operations.include?(:submit_single_message)

      msg_input = build_hl7_message(patient_info)
      begin
        response = client.call(:submit_single_message) do
          message(**sandbox_credentials, hl7Message: msg_input)
        end
      rescue Savon::Error => e
        fault_code = e.to_s
        raise HealthCards::SOAPError, fault_code
      end

      raw_response_message = response.body[:submit_single_message_response][:return]
      response_segments = raw_response_message.to_s.split("\n")
      HL7::Message.new(response_segments)
    end

    # Translate relevant info from V2 Response message into a FHIR Bundle
    # @param v2_response [HL7::Message] V2 message returned from the IIS Sandbox
    # @return [String] FHIR Bundle representation of the V2 message
    def translate_to_fhir(v2_response)
      fhir_response = Faraday.post("#{Rails.application.config.v2ToFhirHost}/api/v0.1.0/convert/text",
                                   v2_response.to_hl7,
                                   'Content-Type' => 'text/plain')
      fhir_response.body
    end

    def build_hl7_message(patient_info) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # Disabling method length Rubocop warnings due to probable future refactor and moving of repos
      raw_input = File.open('lib/assets/qbp.hl7').readlines
      msg_input = HL7::Message.new(raw_input)

      # Build MSH Segment
      uid = rand(10_000_000_000).to_s
      msh = msg_input[:MSH]
      msh.time = Time.zone.now
      msh.message_control_id = uid

      # Build QPD segnment
      qpd = msg_input[:QPD]
      qpd.query_tag = uid

      if patient_info[:patient_list]
        patient_id_list = HL7::MessageParser.split_by_delimiter(qpd.patient_id_list, msg_input.item_delim)
        patient_id_list[1] = patient_info[:patient_list][:id] # ID
        patient_id_list[4] = patient_info[:patient_list][:assigning_authority] # assigning authority
        patient_id_list[5] = patient_info[:patient_list][:identifier_type_code] # identifier type code
        qpd.patient_id_list = patient_id_list.join(msg_input.item_delim)
      end

      if patient_info[:patient_name]
        patient_name = HL7::MessageParser.split_by_delimiter(qpd.patient_name, msg_input.item_delim)
        patient_name[0] = patient_info[:patient_name][:family_name] # family name
        patient_name[1] = patient_info[:patient_name][:given_name] # given name
        patient_name[2] = patient_info[:patient_name][:second_or_further_names] # second name
        patient_name[3] = patient_info[:patient_name][:suffix] # suffix name
        qpd.patient_name = patient_name.join(msg_input.item_delim)
      end

      if patient_info[:mothers_maiden_name]
        mother_maiden_name = HL7::MessageParser.split_by_delimiter(qpd.mother_maiden_name, msg_input.item_delim)
        mother_maiden_name[0] = patient_info[:mothers_maiden_name][:family_name] # family name
        mother_maiden_name[1] = patient_info[:mothers_maiden_name][:given_name] # given name
        mother_maiden_name[6] = patient_info[:mothers_maiden_name][:name_type_code] # name type code, M = Maiden Name
        qpd.mother_maiden_name = mother_maiden_name.join(msg_input.item_delim)
      end

      qpd.patient_dob = patient_info[:patient_dob]

      qpd.admin_sex = patient_info[:admin_sex]

      if patient_info[:address]
        address = HL7::MessageParser.split_by_delimiter(qpd.address, msg_input.item_delim)
        address[0] = patient_info[:address][:street] # street address
        address[2] = patient_info[:address][:city] # city
        address[3] = patient_info[:address][:state] # state
        address[4] = patient_info[:address][:zip] # zip
        address[6] = patient_info[:address][:address_type] # address type
        qpd.address = address.join(msg_input.item_delim)
      end

      if patient_info[:phone]
        phone_home = HL7::MessageParser.split_by_delimiter(qpd.phone_home, msg_input.item_delim)
        phone_home[5] = patient_info[:phone][:area_code] # area code
        phone_home[6] = patient_info[:phone][:local_number] # local number
        qpd.phone_home = phone_home.join(msg_input.item_delim)
      end

      msg_input
    end

    # NOTE: This is a helper method to upload a patient to the IIS Sandbox and should be used for testing purposes only
    # Send a VXU message to the IIS Sandbox service to upload a patient
    # @param vxu_path [String] File Path where HL7 V2 VXU message is located
    def upload_patient(vxu_path = 'lib/assets/vxu_fixtures/vxu.hl7')
      # Define client
      service_def = 'lib/assets/service.wsdl'
      client = Savon.client(wsdl: service_def,
                            endpoint: "#{Rails.application.config.iisSandboxHost}/iis-sandbox/soap",
                            pretty_print_xml: true)
      # Upload Patient from fixture
      upload_raw_input = FILE.open(vxu_path).readlines
      upload_msg_input = HL7::Message.new(upload_raw_input)
      client.call(:submit_single_message) do
        message({ username: Rails.application.config.username,
                  password: Rails.application.config.password,
                  facilityID: Rails.application.config.facilityID,
                  hl7Message: upload_msg_input })
      end
    end

    # Methods That Parse HL7 V2 Message

    # Get the status of a response returned from the IIS Sandbox. Throw Errors for invalid responses.
    # @param msg_response [HL7::Message] The response message returned from an IIS Sandbox QBP Query
    # @return [Symbol] The status of the response from the IIS-Sandbox
    # Return Options:
    #   :OK = Data found, no errors (this is the default)
    #   :NF = No data found, no errors
    #   :AE = Application Error
    #   :TM = Too much data found
    def get_response_status(msg_response)
      # Get QAK.2 (Query Response Status)
      response_status = msg_response[:QAK][2].to_sym

      # Handle Errors for each profile that could be returned; modify response_status if necessary
      profile = msg_response[:MSH][20][0..2].to_sym
      case profile
      when :Z32
        handle_z32_errors(msg_response)
      when :Z31
        handle_z31_errors(msg_response)
        # Setting response status to :TM (Too much data found) to handle case where multiple mathces are returned.
        # Query Response Status (QAK) segment would not indicate the need to input more information in this scenario.
        response_status = :TM
      when :Z33
        handle_z33_errors(msg_response)
      else
        # TODO: Come up with request that can produce an unrecognized response profile
        # (this may require a flavor in the IIS Sandbox)
        raise HealthCards::OperationNotSupportedError
      end

      response_status
    end

    # Methods that check for and handle errors

    def check_client_connectivity(client)
      begin
        response = client.call(:connectivity_test) do
          message echoBack: '?'
        end
      rescue Savon::Error => e
        fault_code = e.to_s
        raise HealthCards::SOAPError, fault_code
      end
      conncectivity_response = response.body[:connectivity_test_response][:return]
      throw HealthCards::BadClientConnectionError unless conncectivity_response == 'End-point is ready. Echoing: ?'
    end

    private

    def valid_credentials?(credentials)
      credentials.each do |_k, v|
        return false unless v.is_a? String
      end
      credentials.keys.sort == [:username, :password, :facilityID].sort
    end

    # Methods to Handle Profile Specific Errors

    # PROFILE Z32 RESPONSE PROFILE - RETURN COMPLETE IMMUNIZATION HISTORY
    def handle_z32_errors(_msg)
      # TODO: Handle RSP K11 Z32 test cases
      nil
    end

    # PROFILE Z31 - RETURN A LIST OF CANDIDATES PROFILE
    def handle_z31_errors(_msg)
      # TODO: Handle RSP K11 Z31 test cases
      nil
    end

    # PROFILE Z33 - RETURN AN ACKNOWLEDGEMENT WITH NO PERSON RECORDS (ERRORS)
    def handle_z33_errors(_msg)
      # TODO: Handle RSP K11 Z323 test cases
      nil
    end
  end
end

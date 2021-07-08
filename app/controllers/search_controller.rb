# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :build_query, only: [:query]

  # GET /search/form
  def form
    @patient = Patient.new(patient_params)
  end

  # POST /search/query
  def query
    results = qbp_query(@query_params)
    case results[:code]
    when :AE
      redirect_to search_form_url,
                  alert: 'Sorry there was an error, please try again. If problem persists contact system administrator.'
    when :AR
      render 'rejected.html.erb'
    when :NF
      render 'no_data.html.erb'
    when :OK
      json_bundle = translate(results[:patient])
      # TODO: - validation here
      render_patient(json_bundle)
    when :PD
      render 'protected.html.erb'
    when :TM
      redirect_to search_form_url, alert: 'Too many matches found, please enter more information.'
    else
      raise StandardError, "QBP client code #{results[:code]} not recognized"
    end
  end

  private

  # only for search#form
  def patient_params
    params[:autofill] ? helpers.real_patient_params[:patient] : {}
  end

  # only for search#query
  def search_params
    input_params = params.require(:patient).permit([:given, :family, :second, :suffix,
                                                    :birth_date, :gender, :phone,
                                                    :list_id, :assigning_authority, :identifier_type_code,
                                                    :mother_maiden_given_name, :mother_maiden_family_name,
                                                    :street_line1, :street_line2, :city, :state, :zip_code]).to_hash
    input_params.transform_keys!(&:to_sym)
    input_params.transform_values!(&:strip)
    input_params.transform_values! { |v| v.empty? ? nil : v }
    input_params
  end

  def build_query
    input_params = search_params
    @query_params = {
      patient_name: input_params.slice(:given, :family, :second, :suffix),
      patient_dob: input_params[:birth_date].split('/').reverse.join,
      patient_list: input_params.slice(:assigning_authority,
                                       :identifier_type_code).merge!({ id: input_params[:list_id] }),
      mother_maiden_name: { family: input_params[:mother_maiden_family_name],
                            given: input_params[:mother_maiden_given_name] },
      sex: input_params[:gender],
      address: input_params.slice(:city, :state).merge!({ zip: input_params[:zip_code] })
    }

    format_street_address(input_params[:street_line1], input_params[:street_line2])
    format_phone_number(input_params[:phone])

    # omitting: :address => { :address_type }
    # omitting: :multiple_birth_indicator, :birth_order, :client_last_updated_date, :client_last_update_facility
  end

  def format_street_address(street_line1 = nil, street_line2 = nil)
    if street_line2 && street_line1
      @query_params[:address][:street] = "#{street_line1}, #{street_line2}"
    elsif street_line1
      @query_params[:address][:street] = input_params[:street_line1]
    end
  end

  def format_phone_number(phone = nil)
    @query_params = { area_code: phone.split('-')[0], local_number: phone.split('-')[1..3].join } if phone
  end

  def render_patient(json)
    if create_patient(json)
      redirect_to(@patient)
    else
      redirect_to(search_form_url,
                  { alert: 'Information from IIS could not be validated.' })
    end
  end

  def create_patient(json)
    bundle = FHIR.from_contents(json)
    @patient = Patient.new({ json: nil })

    bundle.entry.each do |entry|
      case entry.resource.resourceType.upcase
      when 'PATIENT'
        @patient.json = entry.resource.to_json
      when 'IMMUNIZATION'
        @patient.immunizations.build({ json: entry.resource.to_json })
      else
        logger.warn "Unexpected resource #{entry.resource.resourceType} found in bundle from QBP client"
      end
    end

    @patient.save
  end

  # from qbp-client branch
  def qbp_query(query_hash)
    raise NotImplementedError, "Calling QBP Client w/ parameter: #{query_hash}"
  end

  # from qbp-client branch
  def translate(hl7v2_text)
    raise NotImplementedError, "Calling QBP Client w/ parameter: #{hl7v2_text}"
  end

  # TODO
  def validate(fhir_json)
    raise NotImplementedError, "Calling validation on QBP response w/ parameter: #{fhir_json}"
  end
end

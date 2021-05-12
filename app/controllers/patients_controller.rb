# frozen_string_literal: true

# PatientsController manages patients via the Web UI
class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]
  after_action :set_cors_header, only: :show

  # GET /patients or /patients.json
  def index
    @patients = Patient.all
  end

  # GET /patients/1 or /patients/1.json
  def show
    respond_to do |format|
      format.html
      format.fhir_json { render json: @patient.to_json }
      format.json do
        if helpers.verify_token(request.headers)
          render json: @patient.to_json
        else
          render json: { errors: ['Unauthorized code'] }, status: :unauthorized
        end
      end
    end
  end

  # GET /patients/new
  def new
    @patient = Patient.new(new_patient_params)
  end

  # GET /patients/1/edit
  def edit; end

  # POST /patients or /patients.json
  def create
    @patient = Patient.new(patient_params)
    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: 'Patient was successfully created.' }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1 or /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1 or /patients/1.json
  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: 'Patient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_patient
    @patient = Patient.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def patient_params
    params.require(:patient).permit(:given, :family, :gender, :birth_date, :phone, :email, :street_line1,
                                    :street_line2, :city, :state, :zip_code)
  end

  def new_patient_params
    params[:patient] ? patient_params : {}
  end
end

# frozen_string_literal: true

# Handles immunization of patients through web UI
class ImmunizationsController < ApplicationController
  before_action :find_patient, except: :show
  before_action :set_immunization, only: %i[edit update destroy]
  before_action :find_vaccines, only: %i[new edit create update]

  # GET /immunizations/new
  def new
    @immunization = Immunization.new
  end

  # GET /immunizations/1/edit
  def edit; end

  # POST /immunizations or /immunizations.json
  def create
    @immunization = Immunization.new(immunization_params)
    @immunization.patient = @patient

    respond_to do |format|
      if @immunization.save
        format.html { redirect_to @patient, notice: 'Immunization was successfully created.' }
        format.json { render :show, status: :created, location: @immunization }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @immunization.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @immunization = Immunization.find(params[:id])

    render json: @immunization.to_json
  end

  # PATCH/PUT /immunizations/1 or /immunizations/1.json
  def update
    respond_to do |format|
      if @immunization.update(immunization_params)
        format.html { redirect_to patient_path(@patient), notice: 'Immunization was successfully updated.' }
        format.json { render :show, status: :ok, location: @immunization }
      else
        format.html do
          find_vaccines
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @immunization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /immunizations/1 or /immunizations/1.json
  def destroy
    @immunization.destroy
    respond_to do |format|
      format.html { redirect_to @patient, notice: 'Immunization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_immunization
    @immunization = @patient.immunizations.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def immunization_params
    params.require(:immunization).permit(:vaccine_id, :occurrence, :lot_number)
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def find_vaccines
    @vaccines = Vaccine.all
  end
end

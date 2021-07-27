# frozen_string_literal: true

class LabResultsController < ApplicationController
  before_action :find_patient, except: :show
  before_action :set_lab_result, only: %i[index edit update destroy]

  def new
    @lab_result = LabResult.new
  end

  def edit; end

  def index; end

  def create
    @lab_result = LabResult.new(lab_result_params)
    @lab_result.patient = @patient

    respond_to do |format|
      if @lab_result.save
        format.html { redirect_to patient_path(@patient), notice: 'Lab Result was successfully created.' }
        format.json { render :show, status: :created, location: @lab_result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lab_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @lab_result = LabResult.find(params[:id])
    render json: @lab_result.to_json
  end

  def update
    respond_to do |format|
      if @lab_result.update(lab_result_params)
        format.html { redirect_to patient_path(@patient), notice: 'Lab Result was successfully updated.' }
        format.json { render :show, status: :ok, location: @lab_result }
      else
        format.html do
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @lab_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @lab_result.destroy
    respond_to do |format|
      format.html { redirect_to patient_path(@patient), notice: 'Lab Result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lab_result
    @lab_result = @patient.lab_results.find(params[:id])
  end

  def lab_result_params
    params.require(:lab_result).permit(:effective, :status, :code, :result)
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end
end

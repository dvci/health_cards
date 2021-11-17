# frozen_string_literal: true

# PatientsController manages patients via the Web UI
class PatientsController < SecuredController
  before_action :find_patient, except: %i[index new create]

  # GET /patients or /patients.json
  def index
    @patients = Patient.all
  end

  # GET /patients/1 or /patients/1.json
  def show
    respond_to do |format|
      format.html { health_card }
      format.fhir_json { render json: @patient.json }
      format.json { render json: @patient.json }
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
  def find_patient
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

# frozen_string_literal: true

class QRCodesController < ApplicationController
  before_action :find_patient, only: :show

  def new; end

  def create
    contents = JSON.parse(params[:qr_contents])
    @scan_result = HealthCards::Importer.scan(contents)
  end

  def show
    respond_to do |format|
      format.png do
        code = health_card.code_by_ordinal(params[:id].to_i)

        head :not_found and return unless code

        send_data code.image.to_s, type: 'image/png', disposition: 'inline'
      end
    end
  end
end

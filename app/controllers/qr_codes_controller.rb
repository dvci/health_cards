# frozen_string_literal: true

class QRCodesController < ApplicationController
  before_action :create_exporter, only: :show

  def new; end

  def create
    contents = JSON.parse(params[:qr_contents])
    @scan_result = HealthCards::Importer.scan(contents)
  end

  def show
    respond_to do |format|
      format.png do
        image = @exporter.qr_code_image(params[:id].to_i)

        head :not_found and return unless image

        send_data image.to_s, type: 'image/png', disposition: 'inline'
      end
    end
  end
end

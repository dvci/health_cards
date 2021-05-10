# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def set_cors_header
    response.header['Access-Control-Allow-Origin'] = '*'
  end
end

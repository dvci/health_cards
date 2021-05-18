# frozen_string_literal: true

# MetadataController exposes the metadata configuration to identify server capabilities
class MetadataController < ApplicationController
  after_action :set_cors_header

  def capability_statement
    render json: Rails.application.config.metadata
  end

  def operation_definition
    render json: Rails.application.config.operation
  end
end

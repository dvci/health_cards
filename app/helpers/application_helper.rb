# frozen_string_literal: true

module ApplicationHelper
  def format_date(date)
    return if date.nil?

    date.strftime('%m/%d/%Y')
  end
end

# frozen_string_literal: true

module ApplicationHelper
  def format_date(date)
    return if date.nil?

    date.strftime('%m/%d/%Y')
  end

  def convert_time_to_epoch(time)
    (time.to_f * 1000).to_i
  end
end

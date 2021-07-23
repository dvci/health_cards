module LabResultsHelper

  def lab_options(value_set)

    x = value_set.codes.group_by { |code| code.system }.to_a.map do |system|
      [system.first, system.last.map! { |code| [code.display, code.code] }]
    end

    grouped_options_for_select(x)
  end
end

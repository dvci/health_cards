module LabResultsHelper

  def lab_options(value_set)
    value_set.codes.group_by { |code| code.system }.to_a.map do |system|
      [system.first, system.last.map! { |code| [code.display, code.code] }]
    end
  end
end

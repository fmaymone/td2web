# frozen_string_literal: true
module ReportServices
  # Report chart data generator
  module DataGenerators
    # Data Selection class
    class DataSelection
      SelectionOptions = Struct.new(:selection_type, :codes)

      def initialize(team_diagnostic, selection_options)
        @team_diagnostic = team_diagnostic
        @selection_options = selection_options
      end
    end
  end
end

# frozen_string_literal: true

module TeamDiagnostics
  module Errors
    # Error class
    class TeamDiagnosticError < StandardError; end

    # Error class
    class DeploymentIssueError < TeamDiagnosticError
      def initialize(msg)
        case msg
        when String
          super
        when Array
          super(msg.join('; '))
        end
      end
    end

    # Error class
    class QuestionAssignmentError < TeamDiagnosticError; end
  end
end

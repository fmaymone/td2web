module TeamDiagnostics
  module Errors

    class TeamDiagnosticError < StandardError; end

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

    class QuestionAssignmentError < TeamDiagnosticError; end


  end
end

# frozen_string_literal: true

# TeamDiagnostic view helper
module TeamDiagnosticsHelper
  def team_diagnostic_state_pill_class(team_diagnostic)
    {
      TeamDiagnostic::STATE_SETUP => 'warning',
      TeamDiagnostic::STATE_DEPLOYED => 'success',
      TeamDiagnostic::STATE_COMPLETED => 'info',
      TeamDiagnostic::STATE_REPORTED => 'dark',
      TeamDiagnostic::STATE_CANCELLED => 'light'
    }.fetch(team_diagnostic.state.to_sym)
  end

  def team_diagnostic_wizard_step_alert_class(step, team_diagnostic)
    if team_diagnostic.wizard_complete? || step < team_diagnostic.wizard
      'success'
    else
      'secondary'
    end
  end
end

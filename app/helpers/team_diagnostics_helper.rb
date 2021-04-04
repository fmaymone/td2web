# frozen_string_literal: true

# TeamDiagnostic view helper
module TeamDiagnosticsHelper
  def team_diagnostic_state_pill_class(team_diagnostic)
    return 'warning' if team_diagnostic.needs_attention?

    {
      TeamDiagnostic::STATE_SETUP => 'warning',
      TeamDiagnostic::STATE_DEPLOYED => 'success',
      TeamDiagnostic::STATE_COMPLETED => 'info',
      TeamDiagnostic::STATE_REPORTED => 'dark',
      TeamDiagnostic::STATE_CANCELLED => 'danger'
    }.fetch(team_diagnostic.state.to_sym)
  end

  def team_diagnostic_wizard_step_alert_class(step, service)
    return 'warning' if service.step_needs_attention?(step)

    team_diagnostic = service.team_diagnostic
    if team_diagnostic.wizard_complete? || step < team_diagnostic.wizard
      'success'
    else
      'secondary'
    end
  end

  def current_user_has_no_organizations_or_diagnostics?
    current_user.organizations.none? || current_user.team_diagnostics.none?
  end
end

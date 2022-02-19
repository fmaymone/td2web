const TeamDiagnosticFormInitializer = () => {
  const logo_selector = document.getElementById('team_diagnostic_logo');
  const selected_indicator = document.getElementById('team_diagnostic--logo-uploaded-indicator');
  if (logo_selector === null || selected_indicator === null) return;

  logo_selector.addEventListener('change', (e) => {
    selected_indicator.classList.remove('invisible')
  })
}

export default TeamDiagnosticFormInitializer

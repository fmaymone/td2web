const TeamDiagnosticForm = () => {
  const logo_selector = document.getElementById('team_diagnostic_logo');
  const selected_indicator = document.getElementById('team_diagnostic--logo-uploaded-indicator');
  if (logo_selector === null || selected_indicator === null) return;

  logo_selector.addEventListener('change', (e) => {
    selected_indicator.classList.remove('invisible')
  })
}
document.addEventListener("turbolinks:load", TeamDiagnosticForm);

const TeamDiagnosticParticipantImportForm = () => {
  const participant_import_selector = document.getElementById('participant_file_select');
  const submit_button = document.getElementById('participant_import_submit');
  if (participant_import_selector === null || submit_button == null) return;
  
  participant_import_selector.addEventListener('change', (e) => {
    console.log('change');
    submit_button.disabled = false
  })
}
document.addEventListener("turbolinks:load", TeamDiagnosticParticipantImportForm);

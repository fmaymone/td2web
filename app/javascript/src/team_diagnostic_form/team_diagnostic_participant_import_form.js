const TeamDiagnosticParticipantImportFormInitializer = () => {
  const participant_import_selector = document.getElementById('participant_file_select');
  const submit_button = document.getElementById('participant_import_submit');
  if (participant_import_selector === null || submit_button == null) return;
  
  participant_import_selector.addEventListener('change', (e) => {
    submit_button.disabled = false
  })
}

export default TeamDiagnosticParticipantImportFormInitializer

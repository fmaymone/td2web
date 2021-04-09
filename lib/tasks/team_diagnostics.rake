# frozen_string_literal: true

namespace :team_diagnostics do
  desc 'Auto Deploy'
  task deploy: :environment do
    TeamDiagnostic.auto_deploy
  end

  desc 'Send Reminders'
  task remind: :environment do
    TeamDiagnostic.send_reminders
  end

  desc 'Auto Complete'
  task complete: :environment do
    TeamDiagnostic.auto_complete
  end
end

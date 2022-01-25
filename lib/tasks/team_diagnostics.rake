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

  desc 'Auto-Respond'
  task :auto_respond, [:id] => :environment do |_t, args|
    #exit(1) if Rails.env.production?

    team_diagnostic = TeamDiagnostic.find(args[:id])

    puts "--- Auto responding to TeamDiagnostic[#{team_diagnostic.name}] participant surveys"
    team_diagnostic.auto_respond
    puts 'OK'
  end
end

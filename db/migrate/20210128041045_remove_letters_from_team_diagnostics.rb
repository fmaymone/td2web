class RemoveLettersFromTeamDiagnostics < ActiveRecord::Migration[6.0]
  def change
    remove_column :team_diagnostics, :cover_letter
    remove_column :team_diagnostics, :reminder_letter
    remove_column :team_diagnostics, :cancellation_letter
  end
end

class AddWizardToTeamDiagnostics < ActiveRecord::Migration[6.0]
  def change
    add_column :team_diagnostics, :wizard, :integer, null: false, default: 1
  end
end

# frozen_string_literal: true

json.array! @team_diagnostics, partial: 'team_diagnostics/team_diagnostic', as: :team_diagnostic

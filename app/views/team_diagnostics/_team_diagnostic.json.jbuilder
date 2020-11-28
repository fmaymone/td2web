# frozen_string_literal: true

json.extract! team_diagnostic, :id, :organization_id, :user_id, :team_diagnostic_id, :diagnostic_id, :state, :locale, :timezone, :name, :description, :situation, :functional_area, :team_type, :show_members, :contact_phone, :contact_email, :alternate_email, :due_at, :completed_at, :deployed_at, :auto_deploy_at, :reminder_at, :reminder_sent_at, :created_at, :updated_at, :created_at, :updated_at
json.url team_diagnostic_url(team_diagnostic, format: :json)

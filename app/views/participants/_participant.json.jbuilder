# frozen_string_literal: true

json.extract! participant, :id, :teamdiagnostic_id, :state, :email, :phone, :title, :first_name, :last_name, :locale, :timezone, :notes, :created_at, :updated_at
json.url participant_url(participant, format: :json)

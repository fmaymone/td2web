# frozen_string_literal: true

json.extract! diagnostic, :id, :slug, :name, :description, :active, :created_at, :updated_at
json.url diagnostic_url(diagnostic, format: :json)

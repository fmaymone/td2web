# frozen_string_literal: true

json.extract! organization, :id, :name, :slug, :domain, :description, :active, :created_at, :updated_at
json.url organization_url(organization, format: :json)

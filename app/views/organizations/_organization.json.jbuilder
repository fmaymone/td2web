# frozen_string_literal: true

json.extract! organization, :id, :name, :description, :url, :industry, :revenue, :locale, :created_at, :updated_at
json.url organization_url(organization, format: :json)

# frozen_string_literal: true

json.extract! tenant, :id, :name, :slug, :domain, :description, :active, :created_at, :updated_at
json.url tenant_url(tenant, format: :json)

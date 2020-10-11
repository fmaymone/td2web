# frozen_string_literal: true

# Grants view helpers
module GrantsHelper
  def entitlements_for_select(grant)
    entitlements = Entitlement.active.order(slug: :asc)
    options = entitlements.map { |e| ["#{e.slug}: #{e.description}", e.id] }
    options_for_select(options, grant.entitlement_id)
  end
end

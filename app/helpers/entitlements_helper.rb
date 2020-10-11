# frozen_string_literal: true

# View Helper
module EntitlementsHelper
  def appcontext_for_select(entitlement)
    list = AppContext.list
    options_for_select(list.map { |c| [c, c] }, entitlement.reference)
  end

  def invitatation_message_template_options(service)
    options_for_select(service.i18n_key_options.map { |o| [o, o] }, service.invitation.i18n_key)
  end
end

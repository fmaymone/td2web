# frozen_string_literal: true

# View Helper
module UsersHelper
  def roles_for_select(user = nil)
    roles = [Role.admin, Role.staff, Role.translator, Role.facilitator, Role.member]
            .select { |r| current_user.role >= r }
    options_for_select(roles.map { |r| [r.name, r.id] }, user&.role_id)
  end

  def locales_for_select(user = nil)
    locales = GlobalizeLanguage.order(:english_name).map { |l| [l.english_name.t, l.iso_639_1] }
    options_for_select(locales, user&.locale)
  end

  def countries_for_select(user_profile = nil)
    countries = [['United States of America'.t, 'US']] + GlobalizeCountry.order(:english_name).map { |c| [c.english_name.t, c.code] }
    options_for_select(countries, user_profile&.country)
  end
end

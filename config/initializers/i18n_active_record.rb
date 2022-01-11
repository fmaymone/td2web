# frozen_string_literal: true

require 'i18n/backend/active_record'

Rails.application.reloader.to_prepare do
  Translation = I18n::Backend::ActiveRecord::Translation

  begin
    if Translation.table_exists?
      I18n.backend = I18n::Backend::ActiveRecord.new

      I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
      I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
      I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

      I18n.backend = I18n::Backend::Chain.new(I18n::Backend::Simple.new, I18n.backend)
    end

    I18n::Backend::ActiveRecord.configure do |config|
      # config.cleanup_with_destroy = true # defaults to false
    end

    I18n.locale = DEFAULT_LOCALE
  rescue
    puts "DATABASE MISSING..."
  end
end

class String
  def t(options={})
    return '' if self == ''
    I18n.t(self, **options)
  end
end

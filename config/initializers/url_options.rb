# frozen_string_literal: true

HOST_PREFIX = [Rails.configuration.application_host, Rails.configuration.application_port].join(':')

Rails.application.reloader.to_prepare do
  Rails.application.routes.default_url_options[:host] = HOST_PREFIX
  ActiveStorage::Current.host = HOST_PREFIX
end

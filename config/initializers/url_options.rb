# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  application_host_and_port = ENV.fetch('APPLICATION_HOST', 'localhost:3000')
  Rails.application.routes.default_url_options[:host] = application_host_and_port
  ActiveStorage::Current.host = application_host_and_port
end

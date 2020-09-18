# frozen_string_literal: true

require_relative 'version'
require_relative 'boot'

require 'rails/all'

require_relative 'constants'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'dotenv/load'
require 'csv'

module Teamdiagnostic
  # Base Application class
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    ### Custom Application Configuration
    application_host_and_port = ENV.fetch('APPLICATION_HOST', 'localhost:3000')
    application_host = application_host_and_port.split(':').first
    application_port = application_host_and_port.split(':').last
    config.application_host_and_port = application_host_and_port
    config.application_host = application_host
    config.application_port = application_port
    config.email_reply_to = ENV.fetch('EMAIL_REPLY_TO', 'XXX')

    config.hosts = nil # Allow any domain (see: https://github.com/rails/rails/pull/33145)

    config.active_job.queue_adapter = :delayed_job

    config.action_mailer.default_url_options = { host: application_host, port: application_port }

    config.autoload_paths += %w[app/services]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

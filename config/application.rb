# frozen_string_literal: true

require_relative 'version'
require_relative 'boot'

require 'rails/all'

require_relative 'constants'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'dotenv/load'

module Teamdiagnostic
  # Base Application class
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.hosts = nil # Allow any domain (see: https://github.com/rails/rails/pull/33145)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

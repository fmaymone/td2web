# frozen_string_literal: true

host_prefix = [Rails.configuration.application_host, Rails.configuration.application_port].join(':')
Rails.application.routes.default_url_options[:host] = host_prefix
ActiveStorage::Current.host = host_prefix

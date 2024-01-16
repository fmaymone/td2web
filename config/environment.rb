# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  # domain: 'team-coaching-ba8fa90a2744.herokuapp.com',
  domain: 'localhost:3000',
  user_name: 'apikey',
  password: ENV.fetch('SENDGRID_API_KEY', nil),
  authentication: :plain,
  enable_starttls_auto: true
}

# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

# gem 'secure_headers'
gem 'aasm'
gem 'amazing_print'
gem 'audited'
gem 'aws-sdk-s3', require: false
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'bootstrap_form', '~> 4.0'
gem 'clockwork', github: 'Rykian/clockwork'
gem 'connection_pool', '~> 2.4', '>= 2.4.1'
gem 'countries'
gem 'daemons'
gem 'dalli'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'devise', git: 'https://github.com/Bellingham-DEV/devise.git', branch: 'tdv2-tweaks'
gem 'devise-async'
gem 'devise-i18n'
gem 'dotenv'
gem 'foreman'
gem 'froala-editor-sdk'
gem 'globalize', require: true
gem 'i18n'
gem 'i18n-active_record', require: 'i18n/active_record'
gem 'i18n-timezones'
gem 'image_processing'
gem 'imgkit'
gem 'jbuilder'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'liquid'
gem 'listen'
gem 'mini_magick'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
gem 'pdfkit'
gem 'pg', '~> 1.4.0'
gem 'pg_search'
gem 'pry'
gem 'pry-inline'
gem 'pry-rails'
gem 'puma'
gem 'pundit'
gem 'rails', '~> 6.1'
gem 'rails-i18n'
gem 'rexml'
gem 'roo'
gem 'roo-xls'
gem 'sass-rails', '~> 6.0'
gem 'sendgrid-ruby'
gem 'sprockets-rails', git: 'https://github.com/rails/sprockets-rails.git'
gem 'thor', '~> 1.2'
gem 'turbolinks'
gem 'webpacker'
# gem 'wkhtmltopdf-heroku'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'letter_opener_web'
  gem 'rubocop', require: false
  gem 'rubocop-faker', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'action-cable-testing'
  gem 'annotate', require: false
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'pessimize', require: false
  gem 'rack-mini-profiler', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter'
  gem 'rspec-mocks'
  gem 'rspec-rails'
  gem 'rspec-support'
  gem 'simplecov', require: false
  gem 'warden-rspec-rails'
end

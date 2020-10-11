# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# gem 'secure_headers'
gem 'aasm'
gem 'amazing_print'
gem 'audited'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'bootstrap_form', '~> 4.0'
gem 'countries'
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
gem 'jbuilder'
gem 'kaminari'
gem 'kaminari-i18n'
gem 'liquid'
gem 'mini_magick'
gem 'pg'
gem 'pg_search'
gem 'pry'
gem 'pry-inline'
gem 'pry-rails'
gem 'puma'
gem 'pundit'
gem 'rails'
gem 'rails-i18n'
gem 'sass-rails'
gem 'sprockets-rails', git: 'https://github.com/rails/sprockets-rails.git'
gem 'turbolinks'
gem 'webpacker'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'letter_opener_web'
  gem 'rubocop', require: false
  gem 'rubocop-faker', require: false
end

group :development do
  gem 'action-cable-testing'
  gem 'annotate', require: false
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'listen'
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

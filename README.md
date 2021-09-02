# README

TeamDiagnosticV2: A fresh start to TeamDiagnostic.

Rails conventions are followed as well as possible.

# Dependencies

* Ruby 2.7.0
* Rails 6.0
* NodeJS 10-13

# Configuration

## Environment Variables

Environment variables are configured in: `.env`

Copy `env.sample` to `.env`

```
# Example for development environment
# ALL of the following ENVVARS must be set
APPLICATION_DOMAIN=localhost
APPLICATION_HOST="localhost:3000"
APPLICATION_PROTOCOL="http"
EMAIL_REPLY_TO='tda@localhost'
LANG=en_US-UTF-8
RACK_ENV=development
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=enabled
RAILS_MAX_THERADS=5
RAILS_MIN_THERADS=5
RAILS_SERVE_STATIC_FILES=enabled
WEB_CONCURRENCY=2
RAILS_MASTER_KEY=XXX   # see config/credentials/ENVIRONMENT.key
```

### Rails credentials

This application uses encrypted credentials.

Set the encryption key with ENV: `RAILS_MASTER_KEY`

Edit credentials with `bundle exec rails credentials:edit --environment RAILS_ENV`

## Database

# Testing

Run `bundle exec rspec` to run all tests and output a coverage report to `coverage/index`

During development, run `bundle exec guard` in a dedicated terminal for automated tests

# Services (job queues, cache servers, search engines, etc.)

* Puma web server
* DelayedJob workers
* Postgresql RDMS

# Deployment instructions

Update constants in `bin/deploy` as needed for  configuration:

* PASS_COMMAND_STAGING
* STAGING_REMOTE
* STAGING_APP
* PASS_COMMAND_PROD
* PROD_REMOTE
* PROD_APP

`bin/deploy (staging|prod)`

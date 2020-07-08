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

```
# Example for development environment
# ALL of the following ENVVARS must be set
APPLICATION_DOMAIN=localhost
APPLICATION_HOST="localhost:3000"
APPLICATION_PROTOCOL="http"
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

Credentials are set for all environments


## Database 

# Testing

Run `bundle exec rspec` to run all tests and output a coverage report to `coverage/index`

During development, run `bundle exec guard` in a dedicated terminal for automated tests


# Services (job queues, cache servers, search engines, etc.)

# Deployment instructions


# README

TeamDiagnosticV2: A fresh start to TeamDiagnostic.

Rails conventions are followed as well as possible.

# Development Quickstart

```
# Install nvm (Node version manager) from https://nodejs.org/en/download.
# Install Node.js Version 14 and npm dependencies
nvm install 14
nvm use 14
npm install yarn

# Install rbenv (Ruby version manager) from https://github.com/rbenv/rbenv
rbenv install 3.1.4
rbenv local 3.1.4
gem install bundler
bundle install
yarn
bundle exec rake db:create
bunzip2 -k db/seed/tdv1_i18n_data-utf8.sql.bz2
psql tdv2_dev < db/seed/tdv1_i18n_data-utf8.sql
bundle exec rake db:setup db:migrate db:seed

# Start the Rails application server
bin/server
```

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

```
# Development
bundle exec rake db:create
bunzip2 -k db/seed/tdv1_i18n_data-utf8.sql.bz2
psql tdv2_dev < db/seed/tdv1_i18n_data-utf8.sql
bundle exec rake db:setup db:migrate db:seed
```

### Backups

Database backup dumps are stored encrypted in Digital Ocean Spaces.


```
```

Create Backup:

```
# Configure Dokku Postgres for remote backups on Digital Ocean Spaces:
ssh dokku@staging.tdv2.bellingham.dev postgres:backup-auth tdv2staging01 SPACES_ID SPACES_KEY us-east-1 s3v4 https://tdv2staging.sfo2.digitaloceanspaces.com

# Optionally set encryption
ssh dokku@staging.tdv2.bellingham.dev postgres:backup-set-encryption tdv2staging01 ENCRYPTION_KEY

# Backup db instance (first) to spaces folder (second)
ssh dokku@staging.tdv2.bellingham.dev postgres:backup tdv2staging01 tdv2staging01

# Schedule backup of instance for every day at 3am (use crontab format) to spaces folder
ssh dokku@staging.tdv2.bellingham.dev postgres:backup-schedule tdv2staging01 "0 3 * * *" tdv2staging01
```

Export data from staging:

```
ssh dokku@staging.tdv2.bellingham.dev postgres:export tdv2staging01 > tmp/staging.dump
```

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

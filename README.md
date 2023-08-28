# README

TeamDiagnosticV2: A fresh start to TeamDiagnostic.

Rails conventions are followed as well as possible.

# Dependencies

* Ruby 3.1.2
* Rails 6.1
* NodeJS 14

# Development

FIRST!:
* Install docker, docker-compose
* Create `.env` file based on `env.example` (Ask for development `RAILS_MASTER_KEY` value from other developer)
* First time use/setup:

```
docker-compose build
docker-compose run web bin/dev_setup
docker-compose run test rake db:create db:test:prepare
```

## General Use Commands

* Start the stack: `docker-compose up`
* Stop the stack `docker-compose down`
* Run tests: `docker-compose run test rspec` for a single run -or- `docker-compose run test guard` to continuously test
* View/tail logs `docker-compose run web bin/tail_logs`
* Run a command against a service: `docker-compose run web XXXX`
  * Open a console: `docker-compose run web rails console`
  * Open a database console: `docker-compose run web rails dbconsole`
* Fix local file permissions after running a Rails generator within a Docker container: `bin/fix_perms`
  * NOTE: files generated using docker will be owned by root. You will have to change file ownership manually.

## Cleanup
* List running containers: `docker ps`
* Stop running containers: `docker stop XXX`
* Stop the stack and remove containers: `docker-compose down`
* Delete data volumes: `docker volume ls | grep tdv2 | awk '{print $2}' | xargs docker volume rm`
* Delete webapp image: `docker images | grep tdv2-dev | awk '{print $3}' | xargs docker rm`

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
COMPOSE_PROJECT_NAME=tdv2
```

### Rails credentials

This application uses encrypted credentials.

Set the encryption key with ENV: `RAILS_MASTER_KEY`

Edit credentials with `bundle exec rails credentials:edit --environment RAILS_ENV`

## Database

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

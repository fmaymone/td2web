# TDv2 Seed data

Load most seed data via `rake db:seed`

## Loading TDv1 i18n Data into development

### Load SQL for Globalize tables

( This only needs to be done once in development. )

```
bunzip2 -k db/seed/tdv1_i18n_data-utf8.sql.bz2

# Local
psql tdv2_dev < db/seed/tdv1_i18n_data-utf8.sql

# Staging Dokku
ssh dokku@staging.tdv2.bellingham.dev postgres:connect tdv2staging01 < db/seed/tdv1_i18n_data.sql

# Production Heroku (PENDING)
heroku pg:psql --app APPNAME < db/seed/tdv1_i18n_data.sql
```

### Load Migrations

```
# Local
rake db:migrate

# Staging
ssh dokku@staging.tdv2.bellingham.dev run staging.tdv2.bellingham.dev rake db:migrate
```

### Convert TDv1 Globalize Translations to I18n::Translations

( This only needs to be done once in development. The seed data already includes this, so don't run it under normal circumstances.)

```
psql tdv2_dev -c \
"INSERT INTO translations (locale, key, value, created_at, updated_at)
  ( SELECT
    DISTINCT ON (locale,key)
    globalize_languages.iso_639_1 AS locale,
    globalize_translations.tr_key AS key,
    globalize_translations.text AS value,
    now() AS created_at,
    now() AS updated_at
  FROM globalize_translations
  INNER JOIN globalize_languages ON
    globalize_languages.id = globalize_translations.language_id
  WHERE globalize_translations.text IS NOT NULL
  AND globalize_translations.tr_key IS NOT NULL
  ORDER BY locale, key, value
 );"
```

## Export I18n::Translations to CSV

```
bundle exec rake i18n:export FILE=db/seed/translations.csv
```

### Load I18n::Translations from CSV

```
bundle exec rake i18n:import FILE=db/seed/translations.csv
```


## Creating Seed Data

Create service objects in `seed/` and call from `db/seeds.rb`.

Service objects should execute using `call` which should return a boolean.  They should also respond to `errors` to return an array of errors, and `status` to return a boolean )

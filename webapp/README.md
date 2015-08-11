[ ![Codeship Status for thecarevoice/webapp](https://codeship.io/projects/de48cca0-2f3c-0132-8328-26bcc74cb0d4/status)](https://codeship.io/projects/39472)

## Overview

This repository has three parts:

* REST API
* Web Application
* Mobile Web Application

## Running

### Running locally

Running as a standard Rails app:

* Run PostgreSQL and Redis
* installing RVM, Ruby( version 2.1.1),the gem bundler, rails
* running ‘bundle install’
* copy the .example config files
 * app_congig.yml
   * generate the secret_key_base 
 * database.yml
   * change the username for  development database
* load up the database
 * createdb carevoice_development
 * createdb carevoice_staging
  * RAILS_ENV=test bin/rake db:create db:migrate
  * RAILS_ENV=development bin/rake db:create db:migrate
* run the app

Links:

* API Documentation: http://127.0.0.1:3000/api/swagger
* Mail View Test: http://127.0.0.1:3000/mail_view

### Live reload

run guard (if guard didn't start):
```
guard
```

you will see:
```
INFO - LiveReload is waiting for a browser to connect.
```

needs to install chrome extension:
https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei

use chrome to open URL of local rails server, you will see:
```
INFO - Browser connected.
```

### deployment

* Chinese staging: http://carevoice.ekohe.com
* Indian staging: http://carevoiceindia.ekohe.com
* Indian production: http://thecarevoice.com
* Chinese production: http://kangyu.co

## Architecture

### i18n

```config/application.rb``` specifies the ```config.i18n.load_path``` as everything
recursively under config/locales.

We use i18n-tasks to validate, find missing and find unused strings:

https://github.com/glebm/i18n-tasks

A matching test has been created as ```spec/i18n_spec.rb```

## Development

### git-flow

Use git-flow to manage feature and hotfix development:

http://danielkummer.github.io/git-flow-cheatsheet/

### Process

* develop freeze wednesday midnight, deploy to staging
* QA on Thursday against develop/staging (carevoice.ekohe.com)
* Push develop to master (and deploy on prod) on Thursday midnight

### Sublime Text settings

```
{
  "tab_size": 2,
  "translate_tabs_to_spaces": true,
  "trailing_spaces_modified_lines_only": true,
  "trailing_spaces_trim_on_save": true,
  "ensure_newline_at_eof_on_save": true
}
```

### faster startup


Use spring to manage instances of the app in the background:

```
bundle exec spring binstub --all
```

### running the tests continuously

```
bundle exec guard
```

### Backup

An automated backup script (using the backup gem) is regularly backup'ing the database to S3. If the password is changed in database.yml, the backup script will need to be updated too.

### Faster install

Modify ```~/.bundle/config```

```
---
BUNDLE_MIRROR__HTTPS://RUBYGEMS.ORG: http://ruby.taobao.org/
BUNDLE_MIRROR__HTTPS:/RUBYGEMS.ORG: http://ruby.taobao.org/
```

Use:

```
bundle config mirror.https:/rubygems.org http://ruby.taobao.org/
bundle config mirror.http:/rubygems.org http://ruby.taobao.org/
```

### Tasks

Loading translations:

```
rake db:translations:load[config/locales/china.csv]
```

## Troubleshooting

### Console on production system

```
ssh tcv@production.kangyu.co
cd ~/sites/webapp/production/current
rails c production
```

### function distance_in_km(numeric, numeric, numeric, numeric) does not exist

Drop the test database (separate from development or staging) and reinitialize:

```
RAILS_ENV=test rake db:drop db:create db:migrate
```


### undefined method `deep_symbolize_keys' for nil:NilClass

* does your RAILS_ENV match your environment?
* check your config directory

### get readable error message when got 500 error after run Rspec testing for a API endpoint

You can dump error message to a html file. It's readable. For example:
```
File.write('/tmp/rails_error.html', response.body)
```

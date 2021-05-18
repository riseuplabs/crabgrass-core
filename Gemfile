source 'https://rubygems.org'

# ensure github urls use https rather than insecure git protocol.
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

##
#  Core components
##

# Rails is the framework we use.
gem 'rails', '~> 5.2.4'

# Security updates
#https://github.com/sparklemotion/nokogiri/issues/1892
gem 'nokogiri', '~> 1.11.4'

# Rake is rubys make... performing tasks
# locking in to latest major to fix API
gem 'rake', '~> 12.3', require: false

# Application preloader for faster start time
gem 'spring', group: :development

# reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# locking in to latest major to fix API
gem 'i18n', '~> 0.7'

# improved gem to access mysql database
# locking in to latest major to fix API
gem 'mysql2', '~> 0.5.2'

# parsing and generating JSON
# locking in to latest major to fix API
gem 'json', '~> 2.3'

# Markup language that uses indent to indicate nesting
# locking in to latest major to fix API
gem 'haml', '~> 5.0'
gem 'haml-rails', '~> 1.0'

# Extendet scriptable CSS language
# locking in to latest major to fix API
gem 'sass'

##
# Prototype - yes. we still use it.
# we use a fork which is rails 5.x compatible
# tests do not pass for this fork
gem 'prototype-rails', github: 'voxmedia/prototype-rails', ref: 'e385756cbabb5608d1eab47b6416cdd49613c73b'

# Full text search for the database
gem 'thinking-sphinx', '~> 3.4.2'

# Enhanced Tagging lib. Used to tag pages
gem 'acts-as-taggable-on', '~> 6.0'

# Rails 5 migration
##

# ActionView::Helpers::RecordTagHelper moved to external gem
gem 'record_tag_helper', '~> 1.0'

##
# Upgrade pending
##

# Use delayed job to postpone the delta processing
# latest version available. Stick to major release
gem 'ts-delayed-delta', '~> 2.0'

# Page Caching has been removed from rails 4.
# migrate it and drop this.
gem 'actionpack-page_caching'

##
# Single use tools
##

# Pundit, permission system
# latest version available. Stick to major release
gem 'pundit', '~> 1.1'

# Bcrypt for has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'secure_headers', '~> 5.2'

# ?
# locking in to latest major to fix API
gem 'http_accept_language', '~> 2.0'

# Removes invalid UTF-8 characters from requests
# use the latest. No API that could change.
gem 'utf8-cleaner'

# Pagination for lists with a lot of items
# locking in to latest major to fix API
gem 'will_paginate', '~> 3.1'

# state-machine for requests
# locking in to latest major to fix API
gem 'aasm', '~> 3.4'

# lists used for tasks and choices in votes so far
# continuation of the old standart rails plugin
# locking in to latest major to fix API, not really maintained though
gem 'acts_as_list', '~> 0.4'

# Check the format of email addresses against RFCs
# better maintained than validates_as_email
# locking in to latest major to fix API
gem 'validates_email_format_of', '~> 1.6'

##
## GEMS required, and compilation is required to install
##

# Formatting text input
# We extend this to resolve links locally -> GreenCloth
# locking in to latest major to fix API
gem 'RedCloth', '~> 4.2'

##
## required, included with crabgrass
##

# extension of the redcloth markup lang
gem 'greencloth', require: 'greencloth',
                  path: 'vendor/gems/riseuplabs-greencloth-0.1'

# media upload post processing has it's own repo
# version is rather strict for now as api may still change.
gem 'crabgrass_media', '~> 0.3.1', require: 'media'

##
## not required, but a really good idea
##

# detect mime-types of uploaded files
#
gem 'mime-types', require: 'mime/types'

# process heavy tasks asynchronously
# 4.0 is most recent right now. fix major version.
gem 'delayed_job_active_record', '~> 4.0'

# delayed job runner as a deamon
gem 'daemons'

# unpack file uploads
gem 'rubyzip', '~> 1.3', require: false

# load new rubyzip, but with the old API.
# TODO: use the new zip api and remove gem zip-zip
gem 'zip-zip', require: 'zip'

# gnupg for email encryption
#
gem 'mail-gpg', '~> 0.3.3'

##
# Environment specific
##

group :production do
  # js runtime needed to precompile assets
  # runs independendly - so no version restriction for now
  # TODO: check if we want this or nodejs
  gem 'therubyracer'
  # gem 'mini_racer', platforms: :ruby # new default in Rails 5.2
end

group :production, :development do
  # used to install crontab
  gem 'whenever', require: false
  # used to minify javascript
  gem 'uglifier', '>= 1.3.0', require: false
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  # needed for some rake tasks, but not generally.
  gem 'sdoc', require: false
end

group :test do
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'byebug'
end

gem 'web-console', group: :development

group :test, :ci do
  ##
  ## TESTS
  ##

  gem 'factory_bot_rails'
  gem 'faker', '~> 1.0.0'

  # temporary fix for minitest 5.11 issue
  gem 'minitest', '~>5.10.3', require: false

  # contains helper methods like assigns and assert_template
  gem 'rails-controller-testing'

  ##
  ## INTEGRATION TESTS
  ##

  gem 'capybara', require: false

  # Capybara driver with javascript capabilities using phantomjs
  # locked to major version for stable API
  gem 'poltergeist', '~> 1.5', require: false

  # Headless webkit browser for testing, fast and with javascript
  # Version newer than 1.8 is required by current poltergeist.
  gem 'phantomjs-binaries', '~> 2.1.1', require: false

  # The castle_gates tests are based on sqlite
  gem 'sqlite3'
end

gem 'bundler-audit'

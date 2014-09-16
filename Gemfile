source 'https://rubygems.org'

gem 'rails', '~> 3.2.18'
gem 'rake'

# we still use prototype.
# these will be replaced by jquery equivalents at some point:
gem 'prototype-rails'
gem 'prototype_legacy_helper', '0.0.0', :github => 'rails/prototype_legacy_helper'
gem 'respond_to_parent', :github => 'jmoline/respond_to_parent'

## from config/environment.rb

##
## GEMS required, but not included with crabgrass:
##

gem 'i18n'
gem 'mysql2'
gem 'json'
gem 'haml'
gem 'sass'
gem 'http_accept_language'

# thinking-sphinx version 3 requires activerecord >= 3.1 and sphinx >= 2.06
# so, we bind to the latest in the version 2 series.
gem 'thinking-sphinx', '~> 2.1.0', :require => 'thinking_sphinx'

# 3.0.7 introduced a bug: https://github.com/mislav/will_paginate/issues/400
# we should remove this strict version once that is fixed.
gem 'will_paginate', '= 3.0.6'

# Could not get the migration rake task for acts-as-taggable-on 3.x to work
# seems it requires rails 3.2
gem 'acts-as-taggable-on', '~> 2.4.1'
gem 'aasm'          # state-machine for requests
gem 'acts_as_list'  # continuation of the old standart rails plugin
gem 'validates_email_format_of' # better maintained than validates_as_email

##
## GEMS required, and compilation is required to install
##

gem 'RedCloth', '~> 4.2'
gem 'hpricot', '~> 0.8'

##
## GEMS required, included with crabgrass
##

gem 'greencloth', :require => 'greencloth', :path => 'vendor/gems/riseuplabs-greencloth-0.1'
gem 'undress', :require => 'undress/greencloth', :path => 'vendor/gems/riseuplabs-undress-0.2.4'
gem 'uglify_html', :require => 'uglify_html', :path => 'vendor/gems/riseuplabs-uglify_html-0.12'

##
## GEMS not required, but a really good idea
##

gem 'mime-types', :require => 'mime/types'
gem 'delayed_job', '~> 3.0.5'
gem 'rails3_before_render'
gem 'rubyzip', '~> 1.1.0', :require => false

# load new rubyzip, but with the old API.
# TODO: use the new zip api and remove gem zip-zip
gem 'zip-zip', :require => 'zip'

# Assets group according to migration guide:
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-1-to-rails-3-2
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end

group :production, :development do
  gem 'whenever', :require => false  # used to install crontab
  gem 'jsmin', :require => false     # used to minify javascript
end

group :development do
  ##
  ## needed for some rake tasks, but not generally.
  ##
  gem 'rdoc', '~> 3.0'

  gem 'thin', :platforms => :mri_19, :require => false
  gem 'rails-dev-boost', :github => 'thedarkone/rails-dev-boost'
  gem 'rb-inotify', '~> 0.9', :require => false  # used by rails-dev-boost

end

group :test, :development do
  gem 'debugger'
end


## from config/environments/test.rb
group :test do

  ##
  ## GEMS REQUIRED FOR TESTS
  ##

  gem 'factory_girl_rails'
  gem 'faker', '~> 1.0.0'
  gem 'minitest', '~> 2.12', :require => false
  gem 'mocha', '~> 0.12.0', :require => false
  #
  # mocha note: mocha must be loaded after the things it needs to patch.
  #             so, we skip the 'require' here, and do it later.
  #             also, requiring either mocha or minitest here causes zeus to
  #             run tests twice, if using zeus (which you should).
  #

  ##
  ## GEMS REQUIRED FOR INTEGRATION TESTS
  ##

  gem 'capybara', require: false

end

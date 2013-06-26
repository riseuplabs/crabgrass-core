source 'https://rubygems.org'

gem 'rails', '~> 3.0.20', :git => 'git://github.com/rails/rails.git', :branch => '3-0-stable'

gem 'rake', '~> 0.9.2'

gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'

## from config/environment.rb

# required, but not included with crabgrass:
gem 'i18n'#, '~> 0.5'
gem 'thinking-sphinx', '~> 2.0', :require => 'thinking_sphinx'
gem 'will_paginate', '~> 3.0'
gem 'sprockets', '~> 2.2'

gem 'mysql2', '~> 0.2.18'

gem 'json', '~> 1.7.7'

gem 'haml'
gem 'sass'

# required, and compilation is required to install
gem 'RedCloth', '~> 4.2'
gem 'hpricot', '~> 0.8'

# required, included with crabgrass
gem 'greencloth', :require => 'greencloth', :path => 'vendor/gems/riseuplabs-greencloth-0.1'
gem 'undress', :require => 'undress/greencloth', :path => 'vendor/gems/riseuplabs-undress-0.2.4'
gem 'uglify_html', :require => 'uglify_html', :path => 'vendor/gems/riseuplabs-uglify_html-0.12'

# not required, but a really good idea
gem 'mime-types', :require => 'mime/types'
gem 'rubyzip'

gem 'delayed_job', '~> 3.0.5'

gem 'rails3_before_render'

group :production, :development do
  gem 'whenever'
  gem 'jsmin'
end

group :development do
  ##
  ## needed for some rake tasks, but not generally.
  ##
  gem 'rdoc', '~> 3.0'

  gem 'thin', :platforms => :mri_19
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git'
  gem 'rb-inotify', '~> 0.9' # used by rails-dev-boost

  gem 'better_errors'
  gem 'binding_of_caller'
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
  gem 'minitest', '~> 2.12', :require => 'minitest/autorun'
  gem 'mocha', '~> 0.12.0', :require => false
  #
  # mocha note: mocha must be loaded after the things it needs to patch.
  #             so, we skip the 'require' here, and do it later.
  #

  ##
  ## GEMS REQUIRED FOR FUNCTIONAL TESTS
  ##

  #gem 'webrat'

end

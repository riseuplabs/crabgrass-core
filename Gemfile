
source :rubygems

gem 'rails', '2.3.16'

## from config/environment.rb

# required, but not included with crabgrass:
gem 'i18n', '~> 0.5'
gem 'thinking-sphinx', '~> 1.4'
gem 'will_paginate', '= 2.3.16'
gem 'sprockets', "~> 2.1.0"

gem 'mysql'

# required, and compilation is required to install
gem 'RedCloth', '~> 4.2'
gem 'hpricot', '~> 0.8'

# required, included with crabgrass
gem 'greencloth', :require => 'greencloth', :path => 'vendor/gems/riseuplabs-greencloth-0.1'
gem 'undress', :require => 'undress/greencloth', :path => 'vendor/gems/riseuplabs-undress-0.2.4'
gem 'uglify_html', :require => 'uglify_html', :path => 'vendor/gems/riseuplabs-uglify_html-0.12'

# not required, but a really good idea
gem 'mime-types', :require => 'mime/types'

# delayed job for rails 2.x:
gem 'delayed_job', '~> 2.0.7'


group :production, :development do
  gem 'compass', '0.10.6'
  gem 'haml', '~> 3.0'
  gem 'sass', '~> 3.2'
  gem 'compass-susy-plugin', :require => 'susy', :path => 'vendor/gems/compass-susy-plugin-0.8.1'
  gem 'whenever'
  gem 'jsmin'
end

group :development do
  ##
  ## needed for some rake tasks, but not generally.
  ##
  gem 'rdoc', '~> 3.0'

  gem 'mongrel'
end

group :test, :development do
  gem 'ruby-debug'
end


## from config/environments/test.rb
group :test do

  ##
  ## GEMS REQUIRED FOR TESTS
  ##

  gem 'machinist', '~> 1.0' # switch to v2 when stable.
  gem 'faker', '~> 1.0.0'
  gem 'minitest', '~> 2.12', :require => 'minitest/autorun'
  gem 'mocha', '~> 0.10.0', :require => false
  #
  # mocha note: mocha must be loaded after the things it needs to patch.
  #             so, we skip the 'require' here, and do it later.
  #

  ##
  ## GEMS REQUIRED FOR FUNCTIONAL TESTS
  ##

  # FIXME: figure out if we're unit testing.
  #unless defined?(UNIT_TESTING)
    gem 'compass', '0.10.6'
    gem 'haml', '~> 3.0'
    gem 'compass-susy-plugin', :require => 'susy', :path => 'vendor/gems/compass-susy-plugin-0.8.1'
  #end

  #gem 'webrat'

end

##
## load gems useful for testing
##

def try_to_load(name, &block)
  begin
    if block_given?
      yield block
    else
      require name
    end
    return true
  rescue LoadError => exc
    puts "Warning: could not load %s" % name
    return false
  end
end

#try_to_load :mocha do
#  gem 'mocha'
#  require 'mocha'
#end

#try_to_load 'leftright'

try_to_load :blueprints do
  require File.expand_path(File.dirname(__FILE__) + "/../cg_blueprints")
end

#try_to_load 'webrat' do
#  require 'webrat'
#  Webrat.configure do |config|
#    config.mode = :rails
#  end
#end

# try_to_load 'shoulda/rails'


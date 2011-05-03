##
## load gems useful for testing
##
## it is impolite to blow up just because a particular test cannot be
## run without its preferred test library.
##

def try_to_load(*names, &block)
  begin
    names.each do |name|
      require name.to_s
    end
    if block_given?
      yield block
    end
    return true
  rescue LoadError => exc
    puts "Warning, missing gem: " % exc.to_s
    return false
  end
end

#try_to_load :mocha do
#  gem 'mocha'
#  require 'mocha'
#end

#try_to_load 'leftright'

#try_to_load :blueprints, :sham, :faker, :machinist do
#  require File.expand_path(File.dirname(__FILE__) + "/../cg_blueprints")
#end

#try_to_load 'webrat' do
#  require 'webrat'
#  Webrat.configure do |config|
#    config.mode = :rails
#  end
#end

# try_to_load 'shoulda/rails'


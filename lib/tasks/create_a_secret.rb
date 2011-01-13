task :create_a_secret do
  require File.dirname(__FILE__) + '/../../config/directories.rb'
  `rake -s secret > #{CRABGRASS_SECRET_FILE}`
end

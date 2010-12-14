require 'active_record'
require 'action_controller'

# uncomment when debugging:
# reloadable

#
# allowed adding find_by_path to models
#

ActiveRecord::Base.class_eval do
  def self.acts_as_path_findable
    extend PathFinder::FindByPath
  end
end

#
# give controllers 'path options' helpers and 'path parsing' helpers
#

ActionController::Base.send(:include, PathFinder::ControllerExtension)

#
# load all the search filters
#

info 'loading search filters', 2
Dir.glob(SEARCH_FILTERS_DIRECTORY+'/*').each do |subdir|
  Dir.glob("#{subdir}/*.rb").each do |file|
    info "loading #{file}", 3
    require file
  end
end


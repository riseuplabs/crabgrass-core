
require 'active_record'

ActiveRecord::Base.class_eval do
  def self.acts_as_path_findable
    extend PathFinder::FindByPath
  end
end


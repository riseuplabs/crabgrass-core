##
## This extends the tags class in acts_as_taggable_on
##
## This files is included by config/initializers/libraries.rb
## which is loaded after the plugin is loaded and before
## the application.
##

module Extends
  module ActsAsTaggableOn
    extend ActiveSupport::Concern

    included do
      # takes a taggable class and set of taggable ids
      # and returns tags that are on these taggables
      scope :for_taggables, lambda {|klass, ids|
        { :select => 'tags.*, count(name) as count',
          :joins => "INNER JOIN taggings ON tags.id = taggings.tag_id AND taggings.taggable_type = '#{klass}'",
          :conditions => ["taggings.taggable_id IN (?)",ids],
          :group => 'name',
          :order => 'name' }
      }


      scope :for_group, lambda {|options|
        { :select => 'tags.*, count(name) as count',
          :joins => "INNER JOIN taggings ON tags.id = taggings.tag_id AND taggings.taggable_type = 'Page' INNER JOIN page_terms ON page_terms.page_id = taggings.taggable_id",
          :conditions => "MATCH(page_terms.access_ids, page_terms.tags) AGAINST ('#{Page.access_filter(options)}' IN BOOLEAN MODE) AND page_terms.flow IS NULL",
          :group => 'name',
          :order => 'name'
        }
      }
    end
  end
end

ActsAsTaggableOn::Tag.class_eval do
  include Extends::ActsAsTaggableOn
end

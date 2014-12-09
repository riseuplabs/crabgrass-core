module UserExtension
  module Tags
    def self.included(base)
      base.instance_eval do
        serialize_as IntArray, :tag_id_cache
        initialized_by :update_tag_cache, :tag_id_cache

      end

    end
    def tags
      ActsAsTaggableOn::Tag.where(id: tag_id_cache)
    end
  end
end

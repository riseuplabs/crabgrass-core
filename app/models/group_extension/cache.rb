module GroupExtension
  module Cache
    def self.included(base)
      base.extend ClassMethods
    end

    # For groups and users have two cache keys:
    # * the version based for relationships of the group.
    # * the normal one based on updated_at for the group itself
    #
    # So for example a groups network list is cached based on
    # the version cache_key so it refreshes when one of the
    # networks changes.
    #
    # The display of a network inside that list is based on that
    # networks normal cache key. It changes when the network
    # itself changes.
    def version_cache_key
      if new_record?
        cache_key
      else
        "#{self.class.model_name.cache_key}/#{id}-#{version}"
      end
    end

    module ClassMethods
      # Takes an array of group ids and increments the version of all these
      # groups. This should be called when something has changed for these groups
      # that might invalidate something they have cached on their landing page.
      # For example, when the name of a member has changed.
      # This method does not need to be called when membership is changed, the
      # version increment for that is already handled elsewhere.
      def increment_version(ids)
        return unless ids.any?
        self.where(:id => ids).update_all('version = version+1')
      end
    end
  end
end


module GroupExtension
  module Cache
    def self.included(base)
      base.extend ClassMethods
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


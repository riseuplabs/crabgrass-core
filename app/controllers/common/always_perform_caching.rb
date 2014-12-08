module Common::AlwaysPerformCaching
  extend ActiveSupport::Concern

  included do
    hide_action :perform_caching
  end

  def perform_caching
    true
  end

  module ClassMethods
    def perform_caching
      true
    end
  end

end

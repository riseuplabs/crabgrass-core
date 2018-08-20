module Common::AlwaysPerformCaching
  extend ActiveSupport::Concern

  def perform_caching
    true
  end

  module ClassMethods
    def perform_caching
      true
    end
  end
end

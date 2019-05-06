# Turn of logging of fragments read.
module ActionController
  class LogSubscriber < ActiveSupport::LogSubscriber
    def read_fragment(event)
      return
    end
  end
end

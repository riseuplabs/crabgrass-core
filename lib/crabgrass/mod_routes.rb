
module Crabgrass
  class << self

    attr :mod_route_blocks, true

    def mod_routes(&block)
      (self.mod_route_blocks ||= []) << block
    end
  end
end

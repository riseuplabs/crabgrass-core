#
# In development mode, rails is very aggressive about unloading and reloading
# classes as needed. Unfortunately, for crabgrass page types, rails always gets
# it wrong. To get around this, we create static proxy representation of the
# classes of each page type and load the actually class only when we have to.
#

module Crabgrass::Page
  class ClassRegistrar
    def self.proxies
      @@proxies ||= {}
    end

    def self.add(name, options)
      info format('adding page %s', name), 2
      proxies[name] = ClassProxy.new(options.merge(class_name: name))
    end

    def self.list
      proxies.values
    end

    def self.proxy(arg)
      proxies[arg] || ClassProxy.new
    end
  end
end

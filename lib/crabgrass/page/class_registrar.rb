=begin

In development mode, rails is very aggressive about unloading and reloading
classes as needed. Unfortunately, for crabgrass page types, rails always gets
it wrong. To get around this, we create static proxy representation of the
classes of each page type and load the actually class only when we have to.

=end

module Crabgrass::Page
  class ClassRegistrar

    def self.proxies
      @@proxies ||= {}
    end

    def self.add(name, options)
      info 'adding page %s' % name, 2
      self.proxies[name] = ClassProxy.new(options.merge(class_name: name))
    end

    def self.list
      self.proxies.values
    end

    def self.proxy(arg)
      self.proxies[arg] || ClassProxy.new
    end

  end
end

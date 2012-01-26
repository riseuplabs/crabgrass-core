#
# In development mode, rails is very aggressive about unloading and reloading
# classes as needed. Unfortunately, for crabgrass page types, rails always gets
# it wrong. To get around this, we create static proxy representation of the
# classes of each page type and load the actually class only when we have to.
#

module Crabgrass::Page
  class ClassProxy

    attr_accessor :creation_controller, :model, :icon, :class_group, :form_sections,
      :class_name, :full_class_name, :internal, :order, :short_class_name, :forbid_new

    attr_writer :controller

    ORDER = ['text', 'media', 'vote', 'calendar']

    def initialize(arg=nil)
      raise 'error' unless arg.is_a? Hash

      if arg[:class_name]
        arg.each do |key,value|
          method = key.to_s + '='
          self.send(method,value) if self.respond_to?(method)
        end
        self.class_group = [self.class_group] unless self.class_group.is_a? Array
        self.full_class_name = self.class_name
        self.short_class_name = self.class_name.sub("Page","")
        self.order ||= 100
      end
    end

    def definition
      self
    end

    def class_display_name
      symbol = (class_name.underscore + '_display').to_sym
      I18n.t(symbol)
    end

    def class_description
      symbol = (class_name.underscore + '_description').to_sym
      I18n.t(symbol)
    end

    def actual_class
      get_const(self.full_class_name)
    end

    # allows us to get constants that might be namespaced
    def get_const(str)
      str.split('::').inject(Object) {|x,y| x.const_get(y) }
    end

    def create(hash, &block)
      actual_class.create(hash, &block)
    end

    def create!(hash, &block)
      actual_class.create!(hash, &block)
    end

    def build!(hash, &block)
      actual_class.build!(hash, &block)
    end

    def to_s
      full_class_name
    end

    # returns a unique identifier suited to put in a url
    # eg RateManyPage => "rate-many"
    def url
      @url ||= short_class_name.underscore.gsub('_','-').nameize
    end

    #
    # return an array of all the controllers
    #
    def controllers
      @controllers ||= begin
        ary = []
        if @controller.is_a? Array
          ary += @controller
        elsif @controller.is_a? String
          ary << @controller
        end
        if @creation_controller
          ary << @creation_controller
        end
        ary
      end
    end

    #
    # returns the primary controller
    #
    def controller
      @first_controller ||= begin
        if @controller.is_a? Array
          @controller.first
        elsif @controller.is_a? String
          @controller
        end
      end
    end

  end
end


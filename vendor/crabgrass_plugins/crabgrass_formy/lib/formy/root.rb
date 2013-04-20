module Formy

  class Root < Element
    attr_accessor :depth, :current_element
    attr_reader :options

    def initialize(options={})
      super(self,options)
      @depth = 0
      @base = self
      @current_element = [self]
    end

    def first(what=:default)
      @firsts ||= {}
      if @firsts[what].nil?
        @firsts[what] = false
        return 'first'
      else
        return nil
      end
    end

  end

end


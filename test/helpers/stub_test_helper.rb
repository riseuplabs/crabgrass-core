require 'rubygems'
require 'metaid'

module PartialStub
  def stub(&block)
    self.extend(StubbingExtensions) unless @__call_tree

    block.call.each do |method_call_string,response|
      method_call_string.match(%r{([^\(]+)(?:\(([^\)]+)\))?(?:\.)?(.*)?})
      method, args, rest = $1, $2, $3

      args = args ? args.split(',') : []
      args = args.map{|a| eval a, block.binding}

      response = Stub.new{{ rest => response }} unless rest.empty? # recursivly stub demeter responses
      response = eval(response.to_s, block.binding) if response.is_a?(EvaledStubResult) # eval symbol responses

      bypass_stubbed(method)

      @__call_tree[[method, args]] = response
    end
  end

  # Everything but the #stub method will only be added when calling #stub
  module StubbingExtensions
    def self.extended(base)
      base.instance_variable_set '@__call_tree', {}
      base.metaclass.send :alias_method, :method_missing_without_stubbing, :method_missing
      base.metaclass.send :alias_method, :method_missing, :method_missing_for_stubbing
    end

    def rename_method(old, new)
      self.metaclass.class_eval do
        alias_method(new.to_sym, old.to_sym)
        undef_method(old.to_sym)
      end
    end

    def bypass_stubbed(method)
      rename_method(method, bypassed_method_name(method)) if respond_to? method
    end
    def bypassed_method_name(method)
      "#{method}_before_stubbing".to_sym
    end

    def method_missing_for_stubbing(name, *args, &block)
      return @__call_tree[[name.to_s, args]]                      if @__call_tree.has_key?([name.to_s, args])
      return self.send(bypassed_method_name(name), *args, &block) if respond_to? bypassed_method_name(name)
      method_missing_without_stubbing(name, *args, &block)
    end
  end
end

class Stub
  include PartialStub

  def initialize(&block)
    self.stub(&block)
  end
end

def stub(obj, &block)
  obj.extend(PartialStub) unless obj.respond_to? :stub
  obj.stub(&block)
end

class EvaledStubResult < String ; end
def e(s) ; EvaledStubResult.new(s) ; end


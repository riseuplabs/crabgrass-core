# Tests have a dummy after_reload implementation
unless Object.private_methods.include? :after_reload
  require 'after_reload'
end

module CastleGates
  class LockError < StandardError
  end
  mattr_accessor :exception_class
  self.exception_class = LockError

  # For example:
  #
  #   CasteGates.initialize('config/permissions')
  #
  def self.initialize(path)
    require "#{Rails.root}/#{path}"
  end

  def self.define(&block)
    self.instance_eval(&block)
  end

  def self.castle(model_class, &block)
    after_reload(model_class) do |model_class|
      model_class.send(:acts_as_castle)
      model_class.class_eval(&block)
    end
  end

  def self.holder(prefix, name, options=nil, &block)
    Holder::add_holder(prefix, name, options, &block)
  end

  def self.holder_alias(name, options)
    Holder::add_holder_alias(name, options[:model])
  end

end

libraries = ['key', 'gate', 'gate_set', 'acts_as_castle', 'holder_definition', 'holder', 'acts_as_holder', 'associations']
libraries.each do |file|
  require "#{File.dirname(__FILE__)}/castle_gates/#{file}"
end

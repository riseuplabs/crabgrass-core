module CastleGates
  class Engine < ::Rails::Engine
  end

  class LockError < StandardError
  end
  mattr_accessor :exception_class
  self.exception_class = LockError

  # For example:
  #
  #   CasteGates.initialize('config/permissions')
  #
  # require_dependency makes sure the file get's reloaded when
  # models get reloaded in development.
  def self.initialize(path)
    require_dependency "#{Rails.root}/#{path}"
  end

  def self.define(&block)
    self.instance_eval(&block)
  end

  def self.castle(model_class, &block)
    model_class.class_eval(&block)
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

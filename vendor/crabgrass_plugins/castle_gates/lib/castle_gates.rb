
module CastleGates

  class LockError < StandardError
  end

  mattr_accessor :exception_class
  self.exception_class = LockError

  #
  # all holders are defined in the specified block
  # by using 'Holder::add_holder'
  #
  #def self.define_key_holders(&block)
  #  Holder.instance_eval(&block)
  #end

  def self.define(&block)
    self.instance_eval(&block)
  end

  def self.castle(model_class, &block)
    model_class.send(:acts_as_castle)
    model_class.class_eval(&block)
  end

  def self.holder(*args, &block)
    Holder::add_holder(*args, &block)
  end

  def self.holder_alias(name, options)
    Holder::add_holder_alias(name, options[:model])
  end

end

['key', 'gate', 'gate_set', 'acts_as_castle',
  'holder_definition', 'holder', 'acts_as_holder',
  'associations'].each do |file|
  require "#{File.dirname(__FILE__)}/castle_gates/#{file}"
end

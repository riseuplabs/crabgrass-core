
module CastleGates

  class LockError < StandardError
  end

  mattr_accessor :exception_class
  self.exception_class = LockError

  #
  # all holders are defined in the specified block
  # by using 'Holder::add_holder'
  #
  def self.define_key_holders(&block)
    Holder.instance_eval(&block)
  end

end

['key', 'gate', 'gate_set', 'acts_as_castle',
  'holder_definition', 'holder', 'acts_as_holder',
  'associations'].each do |file|
  require "#{File.dirname(__FILE__)}/castle_gates/#{file}"
end

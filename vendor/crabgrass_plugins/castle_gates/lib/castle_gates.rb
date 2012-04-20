
module CastleGates

  class LockError < StandardError
  end

  mattr_accessor :exception_class
  self.exception_class = LockError

end

['key', 'locks', 'gate', 'gate_set', 'acts_as_castle', 'holder', 'acts_as_holder'].each do |file|
  require "#{File.dirname(__FILE__)}/castle_gates/#{file}"
end

require 'active_support'
require 'action_controller'

if defined?(Arel)
  require File.dirname(__FILE__) + '/lib/castle_gates/arel_extension'
end

require File.dirname(__FILE__) + '/lib/castle_gates'

ActiveRecord::Base.class_eval do
  include CastleGates::ActsAsCastle
end

ActionController::Base.class_eval do
  protected

  def key_holders(*args)
    args.collect { |arg| CastleGates::Holder[arg] }
  end

  def find_holder_by_code(code)
    CastleGates::Holder.find_by_code(code)
  end
end

#
# Castle instance methods
#

module CastleGates
module Castle
module InstanceMethods

  def has_access!(lock, holder)
    if has_access?(lock, holder)
      return true
    else
      raise CastleGates.exception_class.new
    end
  end

  def has_access?(lock, holder = User.current)
    holder = :public if holder.is_a? UnauthenticatedUser
    if holder == User.current
      # these might be cached through AR.
      current_user_keys.open?(lock)
    else
      # the named scope might have changed so we need to reload.
      keys.for_holder(holder).open?(lock, true)
    end
  end

  #
  # returns true if the gate is openable by the holder.
  #
  # for example:
  # 
  #   castle.access?(:to => :door, :for => current_user)
  #
  def access?(args)
    holder = Holder.get(args[:for])
    gate   = self.class.gate_set.get(args[:to])
    gate.opened_by? keys.for_holder(holder)
  end

  # # for a single holder call
  # # grant! user.friends, [:pester, :see]
  # #
  # # for multiple holders you can use a hash instead:
  # # grant! :see => :public, :pester => [user.friends, user.peers]
  # #
  # # Options:
  # # :reset => remove all other locks granted to the holders specified
  # #           (defaults to false)
  #def grant!(*args)
  #   options = args.pop if args.count > 1 and args.last.is_a? Hash
  #   Locks.each_holder_with_locks(*args) do |holder, locks|
  #     key = keys.find_or_initialize_by_holder(holder)
  #     key.grant! locks, options
  #     key
  #   end
  # end

  def grant_access!(args)
    holders = args[:for]
    gates = args[:to]
    raise ArgumentError.new('argument must be in the form {:to => x, :for => y}') unless holders and gates

    Holder.list(holders).each do |holder|
      key = keys.find_or_initialize_by_holder_code(holder.code)
      key.add_gates! gates
    end
  end

  # no options so far
  # def revoke!(*args)
  #   Locks.each_holder_with_locks(*args) do |holder, locks|
  #     key = keys.find_or_initialize_by_holder(holder)
  #     key.revoke! locks
  #     key
  #   end
  # end

  # this appears to be only used for testing.
  def keys_by_lock
    keys.inject({}) do |hash, key|
      key.locks.each do |lock|
        hash[lock] ||= []
        hash[lock].push key
      end
      hash
    end
  end

  def gates
    self.class.gates
  end

  ##
  ## CALLBACKS
  ##

  #
  # implement as you will
  #
  def after_key_update(key)
  end

  private

  def as_array(obj)
    if obj.is_a? Array
      obj
    else
      [obj]
    end
  end

end
end
end
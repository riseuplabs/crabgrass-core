#
# Override default const_missing.
# see ActiveSupport::Dependencies
#
module CallbackClassConstMissing
  def const_missing(const_name)
    const = super
    if const
      LoadConstCallback.fire(const)
    end
    return const
  end
end

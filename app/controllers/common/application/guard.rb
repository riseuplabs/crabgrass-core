# This will load /app/permissions/robots_permissions.rb
#
# You can alter the default verb or object with guard_like:
#
#   guard_like 'cyborgs'
#
# NOTE: guard and guard_like settings will NOT be inherited by subclasses.
#
# You can also do this dynamically by defining the methods permission_verb or
# permission_object:
#
#   def permission_object
#     half_human? ? :cyborgs : :robots
#   end
#
#   At the top of your controller definition, do this:
#
#     guard :show => :may_show_robots?,
#           :update => :may_edit_robots?  #
#   This will ensure the may_show_robots? returns true before 'show()' will run.
#   Procs are also allowed, as well as the special symbol :allow. For example
#
#     guard :show => Proc.new { @robot.is_hungry? },
#           :update => :allow
#

module Common::Application::Guard

  ACTION_ALIASES = HashWithIndifferentAccess.new(:update => :edit,
                                                 :new    => :create)

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # Specifies what permission method to use for particular actions.
    #
    # There are two ways of using this:
    #
    #  a) specify a method and list the actions as options.
    #     If no options are given it will be used as the default for all actions.
    #  b) specify a hash with keys representing the actions and values
    #     for the respective methods.
    #
    # e.g.
    #
    #  a) guard :may_change_this?, :actions => [:edit, :update, :destroy]
    #  b) guard :show => :may_show_this?, :update => :may_update_this?
    #
    #  If you include ACTION or ALIAS in the permission method
    #  they will be replaced with the controller action or an alias.
    #  ALIAS will use 'create' for 'new' and 'edit' for 'update' so their
    #  permissions can be combined.
    #
    def guard(*settings)
      if settings.first.is_a? Hash
        action_map.merge settings.first
      else
        add_method_to_action_map(*settings)
      end
    end

    def permission_for_action(action)
      method = action_map[action]
      raise ArgumentError.new("No Permission defined for #{action}") unless method
      permission_cache[action] ||= replace_wildcards(method, action)
    end

    protected

    def action_map
      @action_map ||= inherit_action_map
    end

    private

    def add_method_to_action_map(method, options = {})
      if actions = options[:actions]
        action_map.merge!(build_action_map(method, actions))
      else
        action_map.default=method
      end
    end

    def build_action_map(method, actions)
      actions = [actions] unless actions.is_a? Array
      Hash[actions.map{|action| [action, method]}]
    end

    def replace_wildcards(method, action)
      string = method.to_s
      string.sub!("ACTION", action.to_s)
      string.sub!("ALIAS", (ACTION_ALIASES[action] || action).to_s)
      string.to_sym
    end

    def permission_cache
      @permission_cache ||= HashWithIndifferentAccess.new
    end

    # working around a bug in HashWithIndifferentAccess here
    # see https://rails.lighthouseapp.com/projects/8994/tickets/5724-subclasses-of-hashwithindifferentaccess-dup-the-wrong-class
    def inherit_action_map
      if superclass.respond_to?(:action_map)
        superclass.action_map.dup.tap do |map|
          map.default = superclass.action_map.default
        end
      else
        HashWithIndifferentAccess.new
      end
    end
  end
end

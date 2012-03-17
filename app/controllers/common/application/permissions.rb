#
# Permissions
#
# Helpers and Controller code for handling permissions.
#
# There are four parts to the crabgrass permission system:
#
# (1) permission definition modules in app/permissions.
# (2) controllers specify which permission modules to include.
# (3) access is restricted to controller's actions, either by...
#     (a) manually guarding some actions
#     (b) defining the authorized?() method.
#     (c) using permission auto-guessing.
# (4) views use permission definitions in order to display the right thing
#
#
# (1) Permission Definition
# ---------------------------------
#
# A 'permission' is just a method available to controllers and views
# that returns true or false.
#
# Most permission methods have a standard form:
#
#  def may_{verb}_{object}?
#    ...
#  end
#
# This form is not required, but is highly recommended in most cases.
#
# When attempting to match the current request to the appropriate permission,
# method, params[:action] is the default verb and params[:controller] is the
# default object.
#
# In other words, if the request is 'update' on controller 'robots', then by
# by default we will call 'may_update_robot?' ("robots" gets singularized just
# like in resource paths). These defaults can be changed (see below).
#
# A permission method should return true or false. It may take optional arguments,
# but no arguments should be required.
#
# (2) Controllers include permissions
# -------------------------------------------
#
# class RobotsController < Common::Application
#   permissions :robots
# end
#
# This will load /app/permissions/robots_permissions.rb
#
# You can alter the default verb or object by appending a hash:
#
#   permissions :robots, :object => 'cyborgs'
#
# You can also do this dynamically by defining the methods permission_verb or
# permission_object:
#
#   def permission_object
#     half_human? ? :cyborgs : :robots
#   end
#
# (3) Restricting access to actions
# -------------------------------------------------
#
# There are three ways to apply a permission to a controller action:
#
#   (a) manually guarding actions
#   (b) define the authorized?() method
#   (c) use permission auto-guessing
#
# (a) manually guarding actions
#
#   At the top of your controller definition, do this:
#
#     guard :show => :may_show_robots?,
#           :update => :may_edit_robots?
#
#   This will ensure the may_show_robots? returns true before 'show()' will run.
#
# (b) define the authorized?() method
#
#   In your controller, you can define this protected method:
#
#     def authorized?
#       if params[:action] == 'update' and @robot.sleeping?
#         may_update_robot?
#       else
#         false
#       end
#     end
#
#   Basically, if authorized?() returns false, the user will get a permission
#   denied message.
#
#   NOTE: The 'authorized?' before filter is only called if filter
#         :login_required is active. This should change eventually.
#
# (c) permission auto-guessing
#
#   Common::Application has this default definition of authorized?()
#
#     def authorized?
#       check_permissions!
#     end
#
#   This will attempt to find a permission method that corresponds to the current
#   verb and object. If none are found, then it returns true. If a permission method
#   is found and the test passes, then check_permissions! returns true. If the test
#   failed, then a PermissionDenied exception is raised.
#
#
# (4) Permissions in views
# ------------------------------------------------------------
#
# The permission methods can be called anywhere. It is useful to call them
# before displaying a link, because you don't want to link to something that
# the user is not allowed to do.
#

#
# DEV NOTE:
# The code here relies on this:
#   class Common::Application
#     def controller(); self; end
#   end
# ...and will not work without it.
#

module Common::Application::Permissions

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      helper_method :permission_log
    end
  end

  #SINGULARIZE_ACTIONS = ['update', 'edit', 'show', 'create', 'new']
  #PLURALIZE_ACTIONS = ['index']

  module ClassMethods
    #
    # Specifies a list of permission mixins to be included in the controller
    # and related views.
    #
    # If the last argument is a hash, this will define various options for
    # permissions.
    #
    # for example:
    #
    #   permissions 'robot/swims', :sleeps, :object => 'robot'
    #
    # Will attempt to load the +Robot::SwimsPermission+ and +SleepsPermission+
    # and will set the default object to 'robot'
    #
    def permissions(*class_names)
      if class_names.last.is_a?(Hash)
        @permission_options = HashWithIndifferentAccess.new(class_names.pop)
      end
      for class_name in class_names
        permission_class = "#{class_name}_permission".camelize.constantize
        include(permission_class)
        add_template_helper(permission_class)
      end
    end

    #
    # specifies what permission method to use for particular actions.
    # action_map is a hash in the form {:action => :permission_method}
    #
    # e.g.
    #
    #   guard :show => :may_show_this?, :update => :may_update_this?
    #
    def guard(action_map)
      @action_map = HashWithIndifferentAccess.new action_map
    end

    def permission_action_map
      @action_map || {}
    end

    def permission_options
      @permission_options
    end

  end

  module InstanceMethods
    protected

    # returns +true+ if the +current_user+ is allowed to perform +action+ in
    # +controller+, optionally with some arguments.
    #
    # permissions are resolved in this order:
    #
    # (1) check for a method as specified with guard for the given action
    # (2) check to see if a method is defined that matches may_action_controller?()
    # (3) check to see if a method with aliased actions
    # (4) return false if we had no success so far.
    #

    #
    # This method will raise PermissionDenied if the current user cannot
    # perform the action.
    #
    # It should only be used in places where you are going to catch the exception,
    # or you want permission denied displayed to the user.
    #
    def check_permissions!
      if check_permissions
        true
      else
        raise_denied
      end
      true
    end

    def permission_log
      @permission_log
    end

    def permission_verb
      self.class.permission_options[:verb] if self.class.permission_options
    end

    def permission_object
      self.class.permission_options[:object] if self.class.permission_options
    end

    def check_permissions
      key = [params[:controller],params[:action]]
      method = cache_permission(key) do
        self.class.permission_action_map[params[:action]] or find_permission_method
      end
      if method.is_a? Proc
        method.call
      elsif method
        self.send(method)
      else
        false
      end
    end

    private

    ACTION_ALIASES = {
      'index'  => ['list'],
      'update' => ['edit'],
      'edit'   => ['update'],
      'create' => ['new'],
      'new'    => ['create']
    }

    #
    # I don't know if this is a good idea, but it caches the permission method
    # that we find. It seems reasonable, since trying dozens of possible methods
    # on every request seems excessive, especially since we know what permission
    # method to use from the last time we found it.
    #
    # The only problem is figuring out what key to cache on. Currently, it is
    # just action and controller.
    #
    # We do not cache in development mode, instead, we build a history of the search
    # and which method was selected.
    #
    def cache_permission(key)
      if RAILS_ENV=='development'
        permission_log_setup(key)
        method = yield
        add_permission_log(:decided => method)
        return method
      else
        @@permission_cache ||= {}
        return @@permission_cache[key] ||= yield
      end
    end

    def find_permission_method
      verbs = possible_verbs
      for verb in verbs
        if method = permission_method_exists(verb,method_object)
          return method
        end
      end
      return nil # sadly, nothing found
    end

    # returns the string for the method if it is defined, false otherwise.
    def permission_method_exists(verb, object)
      return false unless verb and object
      methods = ["may_#{verb}_#{object}?"]
      methods << "may_#{verb}_#{object.pluralize}?" if object != object.pluralize
      methods.each do |method|
        add_permission_log(:attempted => method)
        if self.respond_to?(method)
          return method
        end
      end
      return false
    end

    #
    # returns the object specified with permissions
    # or a singularized version of the controller param
    # eg 'groups/requests' -> 'group_request'
    #
    def method_object
      permission_object ||
      params[:controller].
        split('/').
        map{|o| o.singularize}.
        join('_')
    end

    def possible_verbs
      # the possibilities are tried *in order*
      return [permission_verb] if permission_verb
      verbs = [params[:action]]
      verbs += ACTION_ALIASES[params[:action]] if ACTION_ALIASES[params[:action]]
      verbs << 'access'
      return verbs
    end

    # setup what combination we are logging
    def permission_log_setup(key)
      if RAILS_ENV == 'development'
        @permission_log ||= {}
        @permission_log_key = key
        @permission_log[key] = {:attempted => [], :decided => nil}
      end
    end

    # log perm info for the combination
    # available keys are :attempted => "method_name" and :decided => "method_name"
    def add_permission_log(opts = {})
      if RAILS_ENV == 'development'
        log = permission_log[@permission_log_key]
        if opts[:attempted]
          info('PERMISSIONS: attempting %s' % opts[:decided], 2)
          log[:attempted] << opts[:attempted]
        end
        if opts[:decided]
          info('PERMISSIONS: using %s' % opts[:decided], 0)
          log[:decided] = opts[:decided]
        end
      end
    end

  end # end instance methods

end # end module


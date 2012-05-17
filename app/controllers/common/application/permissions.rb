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
# (3) Restricting access to actions
# -------------------------------------------------
#
# There are two ways to apply a permission to a controller action:
#
#   (a) manually guarding actions
#   (b) define the authorized?() method
#
# (a) manually guarding actions
#
#   See Common::Application::Guard for more information.
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
#   NOTE: The 'authorized?' before filter is called from the
#         :login_required before filter or needs to be added to the controller.
#         This should change eventually.
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

  module ClassMethods
    #
    # Specifies a list of permission mixins to be included in the controller
    # and related views.
    #
    # for example:
    #
    #   permissions 'robot/swims', :sleeps
    #
    # Will attempt to load the +Robot::SwimsPermission+ and +SleepsPermission+
    #
    def permissions(*class_names)
      for class_name in class_names
        permission_class = "#{class_name}_permission".camelize.constantize
        include(permission_class)
        add_template_helper(permission_class)
      end
    end

    #
    # Specifies permissions only to be loaded in the related views.
    #
    # for example:
    #
    #   permissions_helper 'robot/dance'
    #
    # will load +Robot::DancePermission+ and make it available in the views.
    #
    def permission_helper(*class_names)
      for class_name in class_names
        permission_class = "#{class_name}_permission".camelize.constantize
        add_template_helper(permission_class)
      end
    end

  end

  module InstanceMethods
    protected

    # returns +true+ if the +current_user+ is allowed to perform +action+ in
    # +controller+, optionally with some arguments.
    #
    # permissions are specified with guard for the given action
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

    def check_permissions
      permission_log_setup(params[:action])
      method = self.class.permission_for_action(params[:action])
      add_permission_log(method)
      case method
      when Proc
        method.call
      when :allow
        true
      when Symbol, String
        self.send(method)
      else
        false
      end
    end

    private

    # setup what combination we are logging
    def permission_log_setup(key)
      if RAILS_ENV == 'development'
        @permission_log ||= {}
        @permission_log_key = key
        @permission_log[key] = nil
      end
    end

    # log perm info for the combination
    def add_permission_log(method)
      if RAILS_ENV == 'development'
        permission_log[@permission_log_key] = method
      end
    end

  end # end instance methods

end # end module


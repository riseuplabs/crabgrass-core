#
# Permissions
# 
# Helpers and Controller code for handling permissions.
#
# There are three parts to the crabgrass permission system:
#
# (1) permission definition modules in app/permissions.
# (2) controllers specify which permission modules to include.
# (3) controllers test for permissions in a before filter.
#
# (1) Permission Definition
# ---------------------------------
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
# class RobotsController < ApplicationController
#   permissions :robots
# end
# 
# This will load /app/permissions/robots_permissions.rb
#
# You can alter the default verb or object by appending a hash:
#
#   permissions :robots, :object => :cyborgs
#
# You can also do this dynamically by defining the methods permission_verb or
# permission_object:
#
#   def permission_object
#     half_human? ? :cyborgs : :robots
#   end
#
# (3) Testing for permission
# -------------------------------------------------
#
# The permission methods can be called anywhere. It is useful to call them
# before displaying a link, because you don't want to link to something that
# the user is not allowed to do.
#
# However, permission methods, in order to be useful, are usually called
# by the controller in a before filter. 
# 
# ApplicationController has this before_filter:
#
#  def authorized?
#    check_permissions!
#  end
#
# This will attempt to find a permission method that corresponds to the current
# verb and object. If none are found, then it returns true. If a permission method
# is found and the test passes, then check_permissions! returns true. If the test
# failed, then a PermissionDenied exception is raised.
#
# Alternately, you can do this manually:
#
# def authorized?
#   if params[:blah]
#     may_blah_blah?
#   else
#     false
#   end
# end
#
# NOTE: The 'authorized?' before filter is only called if filter
#       :login_required is active.
#

# NOTE:
# The code here relies on this:
#   class ApplicationController
#     def controller(); self; end
#   end
# ...and will not work without it.

module ApplicationController::Permissions

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      #helper_method :may?
      #helper_method :may_action?
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
        begin
          permission_class = "#{class_name}_permission".camelize.constantize
        rescue NameError # permissions 'groups' => Groups::BasePermission
          permission_class = "#{class_name}/base_permission".camelize.constantize
        end
        include(permission_class)
        add_template_helper(permission_class)
      end
    end
  end

  module InstanceMethods
    protected

    # returns +true+ if the +current_user+ is allowed to perform +action+ in
    # +controller+, optionally with some arguments.
    #
    # permissions are resolved in this order:
    #
    # (1) check to see if a method is defined that matches may_action_controller?()
    # (2) check the class hierarchy for such a method (replacing controller name
    #     with the appropriate controller).
    # (3) fall back to default_permission
    # (4) return false if we had no success so far.
    #
    #def may?(controller, action, *args)
    #  permission = permission_for_controller(controller, action, *args)
    #  if permission and block_given?
    #    # return nil, if yield returns false
    #    yield
    #  else
    #    permission
    #  end
    #end

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
      nil
    end

    def permission_object
      nil
    end

    def check_permissions
      key = [params[:controller],params[:action]]
      method = cache_permission(key) do
        find_permission_method
      end
      if method
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

    puts '#################################################'
    puts caller

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
      objects = possible_objects
      verbs = possible_verbs
      for verb in verbs
        for object in objects
          if method = permission_method_exists(verb,object)
            return method
          end
        end
      end
      return nil # sadly, nothing found
    end
    
    # returns the string for the method if it is defined, false otherwise.
    def permission_method_exists(verb, object)
      return false unless verb and object
      methods = ["may_#{verb}_#{object}?"]
      methods << "may_#{verb}_#{object.singularize}?" if object != object.singularize
      methods << "may_#{verb}_#{object.pluralize}?" if object != object.pluralize
      methods.each do |method|
        add_permission_log(:attempted => method)
        if self.respond_to?(method)
          return method
        end
      end
      return false
    end

    def possible_objects
      # the possibilities are tried *in order*
      objects = []
      objects << permission_object
      objects << params[:controller].sub('/','_')      # eg 'me/requests' -> 'me_requests'
      objects << params[:controller].sub(/^.*\//, '')  # eg 'me/requests' -> 'requests'
      objects << params[:controller].sub(/\/.*$/, '')  # eg 'me/requests' -> 'me'
      return objects
    end

    def possible_verbs
      # the possibilities are tried *in order*
      verbs = []
      verbs << permission_verb
      verbs << params[:action]
      verbs += ACTION_ALIASES[params[:action]] if ACTION_ALIASES[params[:action]].any?
      verbs << 'access'
      return verbs
    end

    # searches for an appropriate permission definition for +controller+.
    #
    # permissions are generally in the form may_{action}_{controller}?
    #
    # Both the plural and the singular are checked (ie GroupsController#edit will
    # check may_edit_groups? and may_edit_group?). Whichever one is first defined
    # will be used.
    #
    # For the 'controller' part, many different possibilities are tried,
    # in the following order:
    #
    # 1) the controller name:
    #    asset_controller -> asset
    # 2) the name of the controller's parent namespace:
    #    me/trash_controller -> me
    #    base_page/share_controller -> page ("base_" is stripped off)
    # 3) the name of the controller's super class:
    #    event_page_controller -> page ("base_" is stripped off)
    # 4) ensure "page" is in there somewhere if controller descends from
    #    BasePageController (the controller might be a subclass of a subclass
    #    of base page)
    #
    # Note: 'base_xxx' is always converted into 'xxx'
    #
    # Alternately, if controller is a string:
    #
    # 1) the string
    #    'groups' -> groups
    # 2) the postfix
    #    'groups/memberships' -> memberships
    # 3) the prefix
    #    'groups/memberships' -> 'groups'
    #
    # Alternately, if controller is a symbol:
    #
    # 1) the symbol
    #
    # Lastly, if the action consists of two words (ie 'eat_soup'), the
    # the permissions without a controller name is attempted (ie 'may_eat_soup?)
    #
#    def permission_for_controller(controller, action, *args)
#      permission_log_setup(controller, action, args)
#      names=[]
#      if controller.is_a? ApplicationController
#        names << controller.controller_name
#        names << controller.controller_path.split("/")[-2]
#        names << controller.class.superclass.controller_name
#        names << 'page' if controller.is_a? BasePageController
#        target = controller
#      elsif controller.is_a? String
#        if controller =~ /\//
#          names = controller.split('/').reverse
#        else
#          names << controller
#        end
#        target = self
#      elsif controller.is_a? Symbol
#        names << controller.to_s
#        target = self
#      end
#      names.compact.each do |name|
#        name.sub!(/^base_/, '')
#        methods = ["may_#{action}_#{name}?"]
#        methods << "may_#{action}_#{name.singularize}?" if name != name.singularize
#        methods << "may_#{action}?" if action =~ /_/
#        methods.each do |method|
#          add_permission_log(:attempted => method)
#          if target.respond_to?(method)
#            add_permission_log(:decided => method)
#            return target.send(method, *args)
#          end
#        end
#      end
#      #if target.respond_to?('default_permission')
#      #  add_permission_log(:attempted => 'default_permission', :decided => 'default_permission')
#      #  return target.send('default_permission', *args)
#      #end
#      return nil
#    end

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


##
## DISABLED STUFF
##

#  # Generate a link to the specific action if the user is allowed to do
#  # so, skipping it otherwise.
#  #
#  # Examples:
#  #   <%= link_if_may("Create a Group", :group, :create) %>
#  #   <%= link_if_may("Edit this Group", :group, :edit, @group) %>
#  #   <%= link_if_may("Delete this Group", :group, :delete, @group, :confirm => "Are you sure?") %>
#  #   <%= link_if_may("Boldly go", :warp_drive, :enable, nil, {}, {:style => "font-weight: bold;"} %>
#  def link_if_may(link_text, controller, action, object = nil, link_opts = {}, html_opts = nil)
#    if may?(controller, action, object)
#      object_id = params_object_id(object)
#      link_to(link_text, {:controller => controller, :action => action, :id => object_id}.merge(link_opts), html_opts)
#    end
#  end

#  def link_to_active_if_may(link_text, controller, action, object = nil, link_opts = {}, active=nil)
#    if may?(controller, action, object)
#      object_id = params_object_id(object)
#      link_to_active(link_text, {:controller => controller.to_s, :action => action, :id => object_id}.merge(link_opts), active)
#    end
#  end

#  # matches may_x?
#  PERMISSION_METHOD_RE = /^may_([_a-zA-Z]\w*)\?$/

#  # Call may?() if the missing method is in the form of a permission test (may_x?)
#  # and call super() otherwise.
#  #
#  # There are two exceptions to this rule:
#  #
#  # (1) We do not call super() if we are a controller. Instead, just throw an error.
#  # this forces every controller to explictly define all its actions. It is just too
#  # difficult to try to support anything else.
#  #
#  # (2) We do not call super() if the superclass does not have method_missing
#  # defined, since this will cause an error.
#  #
#  def method_missing(method_id, *args)
#    method_id = method_id.to_s
#    match = PERMISSION_METHOD_RE.match(method_id)
#    if match
#      result = may?(controller, match[1], *args)
#      if result.nil?
#        raise Exception.new('could not find permission definition for %s' % method_id)
#      else
#        result
#      end
#    elsif self.is_a? ActionController::Base
#      raise NameError, "No method #{method_id}. (NOTE: due to the way permissions work, you must explicitly define each action in a controller).", caller
#    elsif self.class.superclass.method_defined?(:method_missing)
#      super
#    else
#      raise NameError, "No method #{method_id}", caller
#    end
#  end

#  private

  
#  # the first one that makes sense in this order: object.name, object.id, nil
#  def params_object_id(object)
#    object_id = if object.respond_to?(:name)
#      object.name
#    elsif !object.blank?
#      object.id
#    end
#  end




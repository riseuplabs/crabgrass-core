#
# Context: a class to represent the current context.
#
# Eventually, Context may become an ActiveRecord, to allow users to
# customize the appearance and behavior of their context.
#
# Identity Context
# -------------------
#
# An identity context sets the "place" for a person or group. It tells use where
# we are and what we can do here. Most importantly, it gives us a sense of the
# identify of the person or group whose space we are in.
#
# Context Banner
# -----------------------
#
# The banner is the main display that shows the current context.
#
# Available options:
#
#  :size     -- [:small | :large]
#  :avatar   -- [true | false]
#

class Context
  extend ActiveModel::Naming

  attr_accessor :tab
  attr_accessor :entity
  attr_accessor :parent
  attr_accessor :navigation
  attr_accessor :breadcrumbs

  # appearance:
  attr_accessor :size
  attr_accessor :avatar
  attr_accessor :fg_color
  attr_accessor :bg_color
  attr_accessor :bg_image
  attr_accessor :bg_image_position

  delegate :to_param, to: :entity
  delegate :id, to: :entity

  def to_model
    self
  end

  # attr_accessor :links
  # attr_accessor :form

  # returns the correct context for the given entity.
  def self.find(entity)
    return nil if entity.blank?
    name = entity.class.name.demodulize
    "Context::#{name}".constantize.new(entity)
  end

  def initialize(entity)
    self.entity = entity
    define_crumbs
    self.size = :large
    self.avatar = true
    self.bg_color = '#ccc'
    self.fg_color = 'white'
  end

  def self.model_name
    @_model_name ||= wrapped_base_class.model_name.dup.tap do |name|
      name.singleton_class.send(:define_method, :param_key) { 'context_id' }
      name.singleton_class.send(:define_method, :singular_route_key) { 'context' }
    end
  end

  # class to base the model name on for using the context in url_for etc.
  # Currently this is either Group or User.
  def self.wrapped_base_class
    raise "please implement wrapped_base_class in #{name}"
  end

  def push_crumb(object)
    if breadcrumbs.nil?
      self.breadcrumbs = []
      self.tab = object
    end
    breadcrumbs << object
  end

  def banner_partial
    '/layouts/context/normal_banner_content'
  end

  protected

  def define_crumbs; end
end

class Context::Group < Context
  def self.wrapped_base_class
    ::Group
  end

  def define_crumbs
    push_crumb :groups
    push_crumb entity if entity and !entity.new_record?
  end
end

class Context::Network < Context::Group
  def define_crumbs
    push_crumb :networks
    push_crumb entity if entity and !entity.new_record?
  end
end

class Context::Committee < Context::Group
  def define_crumbs
    push_crumb :groups
    if entity and !entity.new_record?
      push_crumb entity.parent
      push_crumb entity
    end
  end

  def banner_partial
    '/layouts/context/nested_banner_content'
  end
end

class Context::Council < Context::Committee
end

class Context::User < Context
  def self.wrapped_base_class
    ::User
  end

  def self.model_name
    @_model_name ||= ::User.model_name.tap do |name|
      name.singleton_class.send(:define_method, :param_key) { 'context_id' }
      name.singleton_class.send(:define_method, :singular_route_key) { 'context' }
    end
  end

  def define_crumbs
    push_crumb :people
    push_crumb entity if entity and !entity.new_record?
  end
end

class Context::Ghost < Context::User
  def define_crumbs
    push_crumb :people
  end

  def banner_partial
    '/layouts/context/hidden_banner_content'
  end
end

class Context::Me < Context
  def self.wrapped_base_class
    ::User
  end

  def define_crumbs
    push_crumb :me
  end
end

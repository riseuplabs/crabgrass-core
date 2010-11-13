require 'activesupport'

class Permission < ActiveRecord::Base
  belongs_to :object, :polymorphic => true

  named_scope :for_user, lambda { |user|
    { :select => '*, BIT_OR(mask) as or_mask',
      :conditions => "entity_code IN (#{user.entity_access_cache.join(", ")})" }
  }

  def allows?(keys)
    not_allowed = bits_for_keys(keys) & ~bitmask
    not_allowed == 0
  end

  def allow!(keys, options = {})
    if options[:reset]
      self.mask = bits_for_keys(keys)
    else
      self.mask |= bits_for_keys(keys)
    end
    save!
  end

  def disallow!(keys)
    self.mask &= ~bits_for_keys(keys)
    save!
  end

  protected

  # we add an or_mask to the permissions when getting the
  # current_user_permission_set. This contains all permissions the
  # user has through different groups. If it's there - use it.
  def bitmask
    self.respond_to?(:or_mask) ?
      or_mask.to_i :
      mask
  end

  def bits_for_keys(keys)
    keys = [keys] unless keys.is_a? Array
    keys.inject(0) {|any, key| any | object.class.bit_for(key)}
  end

end

module ActsAsPermissive

  class PermissionError < StandardError; end;

  def self.included(base)
    base.class_eval do
      # This allows you to define permissions on the object that acts as permissive.
      # Permission resolution uses entity codes so that we can resolve permissions
      # via groups without joins

      def self.acts_as_permissive(*permissions)
        has_many :permissions, :as => :object

        # let's use AR magic to cache permissions from the controller like this...
        # @pages = Page.find... :include => {:owner => :current_user_permission_set}
        has_one :current_user_permission_set,
          :class_name => "Permission",
          :as => :object,
          :select => '*, BIT_OR(mask) as or_mask',
          :conditions => 'entity_code IN (#{User.current.entity_access_cache.join(", ")})'

        class_eval do
          def allows?(keys, options = {})
            if user=options[:to_user]
              permissions.for_user(user).allows?(keys)
            else
              current_user_permission_set.allows?(keys)
            end
          end

          def allow!(entity, keys, options = {})
            permission = permissions.find_or_initialize_by_entity_code(entity.entity_code)
            permission.allow! keys, options
          end

          def disallow!(entity, keys)
            permission = permissions.find_or_initialize_by_entity_code(entity.entity_code)
            permission.disallow! keys
          end

          def self.bit_for(key)
            ActsAsPermissive::Permissions.bit_for(self.name, key)
          end

          def self.add_permissions(*keys)
            keys = keys.first if keys.first.is_a? Enumerable
            ActsAsPermissive::Permissions.add_bits(self.name, keys)
          end
        end
        if permissions.any?
          self.add_permissions(*permissions)
        end
      end
    end
  end

  module Permissions

    def self.add_bits(class_name, keys)
      @@hash ||= {}
      class_hash = @@hash[class_name] ||= {}
      if keys.is_a? Hash
        keys.reject!{|k,v| class_hash.keys.include? k}
      elsif keys.is_a? Enumerable
        keys.reject!{|k| class_hash.keys.include? k}
      end
      class_hash.merge! build_bit_hash(keys, @@hash[class_name].count)
    end

    def self.bit_for(class_name, key)
      bit = @@hash[class_name][key.to_s.downcase.to_sym]
      if bit.nil?
        raise ActsAsPermissive::PermissionError.new("Permission '#{key}' is unknown to class '#{class_name}'")
      else
        bit
      end
    end

    protected
    def self.build_bit_hash(keys, offset)
      bitwise_hash = {}
      if keys.is_a? Hash
        keys.each do |key, value|
          bitwise_hash[key] = 2 ** value
        end
      elsif keys.is_a? Enumerable
        keys.each_with_index do |key, index|
          bitwise_hash[key] = 2 ** (index + offset)
        end
      end
      bitwise_hash
    rescue ArgumentError
      raise ActsAsPermissive::PermissionError.new("Permission bits must be integers or longs.")
    end
  end
end


module Crabgrass
  module Validations
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
      # validates_handle makes sure that
      # (1) the handle is in a good format
      # (2) the handle is not taken by an existing group or user
      # (3) the handle does not collide with our routes or controllers
      #
      def validates_handle(*attr_names)
        # configuration = { :message => I18n.translate('activerecord.errors.messages.invalid'), :on => :save, :with => nil }
        # ^^ this often doesn't work. I am not sure why, but I think it is because we haven't set a language yet.
        #    also, i can't imagine how this is supposed to work. 'validates_handle' is called once at startup, but
        #    we want to translate the error messages different for each request, since we don't know what the language
        #    should be outside the request.  -elijah

        # configuration = { :on => :save, :with => nil }
        # ^^ only validating the handle :on => :save currently breaks the tests,
        #    as they use 'create' instead of 'save', and possibly allows creating
        #    stuff without validating the handle.
        configuration = { with: nil }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value.present?
            record.errors.add(attr_name, 'must exist')
            next # can't use return cause it raises a LocalJumpError
          end
          unless (3..50).cover? value.length
            record.errors.add(attr_name, 'must be at least 3 and no more than 50 characters')
          end
          unless /^[a-z0-9]+([-\+_]*[a-z0-9]+){1,49}$/ =~ value
            record.errors.add(attr_name, 'may only contain letters, numbers, underscores, and hyphens')
          end
          unless record.instance_of?(Group::Committee) || record.instance_of?(Group::Council)
            # only allow '+' for Committees
            if /\+/ =~ value
              record.errors.add(attr_name, 'may only contain letters, numbers, underscores, and hyphens')
            end
          end
          if FORBIDDEN_NAMES.include?(value)
            record.errors.add(attr_name, 'is already taken')
          end
          previous = User.find_by_login(value) || Group.find_by_name(value)
          if previous.present? && previous != record
            record.errors.add(attr_name, 'is already taken')
          end
        end
      end
    end
  end
end

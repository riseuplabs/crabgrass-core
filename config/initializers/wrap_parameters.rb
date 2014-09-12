#
# UNUSED: This is a default since rails 3.1
# ( http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-0-to-rails-3-1 )
#
# We're not using json responses much and i think we do not make
# use of any of this. But since it's in by default...
#

# Be sure to restart your server when you modify this file.
# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end

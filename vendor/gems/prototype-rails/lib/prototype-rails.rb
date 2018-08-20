require 'rails'
require 'active_support'

module PrototypeRails
  class Engine < Rails::Engine
    initializer 'prototype-rails.initialize' do
      ActiveSupport.on_load(:action_controller) do
        require 'prototype-rails/on_load_action_controller'
      end

      ActiveSupport.on_load(:action_view) do
        require 'prototype-rails/on_load_action_view'
      end
    end
  end
end


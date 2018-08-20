require 'action_view/helpers/prototype_helper'
require 'action_view/helpers/scriptaculous_helper'
require 'action_view/template/handlers/rjs'
require 'prototype-rails/javascript_helper'
require 'prototype-rails/rendering'

ActionView::Base.class_eval do
  cattr_accessor :debug_rjs
  self.debug_rjs = false
end

ActionView::Base.class_eval do
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::ScriptaculousHelper
end

if defined?(Rails.env) && Rails.env.test?
  ActionView::TestCase.class_eval do
    include ActionView::Helpers::PrototypeHelper
    include ActionView::Helpers::ScriptaculousHelper
  end
end

ActionView::Template.register_template_handler :rjs, ActionView::Template::Handlers::RJS.new

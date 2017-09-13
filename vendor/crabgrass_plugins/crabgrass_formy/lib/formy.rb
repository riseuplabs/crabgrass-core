module Formy
  FORM_CLASS = 'form'.freeze
  ROW_CLASS = 'form-row'.freeze
  LABEL_CLASS = 'form-label'.freeze
  INFO_CLASS = 'form-info'.freeze
  INPUT_CLASS = 'form-input'.freeze
  TITLE_CLASS = 'form-title'.freeze
  HEADING_CLASS = 'form-heading'.freeze
  BUTTONS_CLASS = 'form-buttons'.freeze
  SPACER_CLASS = 'form-spacer'.freeze
end

require 'formy/element'
require 'formy/root'
require 'formy/base_form'
require 'formy/buffer'

require 'formy/simple_form'
require 'formy/horizontal_form'
require 'formy/tab'
require 'formy/tabs'
require 'formy/cutout_tabs'
require 'formy/toggle_bugs'

module Formy
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'active_support'
require 'action_view'

require 'formy'
require 'formy/helper'

module Rails
  def self.env
    'development'
  end
end

class Testr
  include ActionView::Helpers
  include Formy::Helper

  def horizontal
    formy(:horizontal_form) do |f|
      f.row do |r|
        r.label 'display name', 'user_display_name'
        r.input text_field 'user', 'display_name'
        r.info 'this little tip should help.'
      end
      f.row do |r|
        r.label 'email address', 'user_email'
        r.input text_field 'user', 'email'
      end
      f.button '<input type="submit">Save</input>'
    end
  end

  def tabs
    formy(:tabs) do |f|
      f.tab do |t|
        t.label 'Tab One'
        t.show_tab 'tab-one-div'
        t.selected true
      end
      f.tab do |t|
        t.label 'Tab Two'
        t.show_tab 'tab-two-div'
        t.selected false
      end
    end
  end

  def simple
    formy(:simple_form) do |f|
      f.row do |r|
        r.label 'display name', 'user_display_name'
        r.input text_field 'user', 'display_name'
      end
      f.row do |r|
        r.label 'email address', 'user_email'
        r.input text_field 'user', 'email'
      end
      f.row do |c|
        c.label 'user is active'
        c.input check_box 'user', 'active'
        c.info 'if checked, the user is left handed'
      end
      f.button '<input type="submit">Save</input>'
      f.button '<input type="submit">Cancel</input>'
    end
  end

  def toggle_bugs
    formy(:toggle_bugs) do |f|
      f.bug do |t|
        t.label 'Tab One'
        t.show_tab 'tab-one-div'
        t.selected true
      end
      f.bug do |t|
        t.label 'Tab Two'
        t.show_tab 'tab-two-div'
        t.selected false
      end
    end
  end

  def run
    %w[simple tabs horizontal toggle_bugs].each do |method|
      puts
      puts '=' * 60
      puts '== ' + method
      puts
      puts send(method)
    end
  end
end

Testr.new.run

$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
gem 'activesupport', '> 2.3.0', '< 3.0'
gem 'actionpack', '> 2.3.0', '< 3.0'
require 'active_support'
require 'action_view/helpers'

require 'formy'
require 'formy/helper'

RAILS_ENV = 'developmentx'

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
    end
  end

  def run
    ['simple', 'tabs', 'horizontal'].each do |method|
      puts
      puts '='*60
      puts '== ' + method
      puts
      puts self.send(method)
    end
  end

end


Testr.new.run


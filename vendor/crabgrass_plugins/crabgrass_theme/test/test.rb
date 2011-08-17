
RAILS_ENV = 'development'
RAILS_ROOT = File.dirname(__FILE__) + '/../../../..'
module Rails
  def self.env
    RAILS_ENV
  end
  def self.root
    RAILS_ROOT
  end
end

$: << 'lib/crabgrass'
$: << RAILS_ROOT

require 'rubygems'
require 'active_record'
require 'app/models/avatar'
require 'lib/crabgrass/theme'

#
# someday, we will write some real tests
#

# test navigation

#theme = Crabgrass::Theme['default']
#theme.navigation.root.each do |nav_element|
#  puts nav_element.visible
#end
#theme.navigation.root

# test inheritance

theme = Crabgrass::Theme['blueberry']
#p theme.background_color
p theme.navigation.root


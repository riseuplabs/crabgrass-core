module Rails
  def self.env
    'development'
  end

  def self.root
    Pathname.new(__FILE__) + '../../../../..'
  end
end

$LOAD_PATH << 'lib/crabgrass'
$LOAD_PATH << Rails.root

require 'rubygems'
require 'active_record'
require 'app/models/avatar'
require 'lib/crabgrass/theme'

#
# someday, we will write some real tests
#

# test navigation

# theme = Crabgrass::Theme['default']
# theme.navigation.root.each do |nav_element|
#  puts nav_element.visible
# end
# theme.navigation.root

# test inheritance

theme = Crabgrass::Theme['blueberry']
# p theme.background_color
p theme.navigation.root

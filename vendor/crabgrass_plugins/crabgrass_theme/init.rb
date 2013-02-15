require 'sass'
require 'crabgrass/theme'
require 'crabgrass/theme/helper'
ActionView::Base.send(:include, Crabgrass::Theme::Helper)

#
# We handle the rendering of sass files ourselves, via the crabgrass_theme plugin.
# (The theme generates sass that includes variables set by the theme)
#
# Consequently, it is important that we force sass to not automatically render
# the css files itself.
#
Sass::Plugin.options[:never_update] = true

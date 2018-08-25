## Javascript

# ie specific js
Rails.application.config.assets.precompile += ['shims.js']

## Stylesheets

Rails.application.config.assets.precompile += ['icon_png.css']

# optional styles for ie6 and ie7 - poorly ported from 0.5
# Rails.application.config.assets.precompile += ['ie6.css', 'ie7.css']
#
## Stylesheets
# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path
# FIXME: Check if we have any!
Rails.application.config.assets.paths << Rails.root.join('node_modules')


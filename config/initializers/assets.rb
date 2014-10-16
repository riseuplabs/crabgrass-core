# optional gif stylesheet for ie6 and ie7
Rails.application.config.assets.precompile += ['icon_gif.css', 'icon_png.css']

# optional styles for ie6 and ie7 - poorly ported from 0.5
Rails.application.config.assets.precompile += ['ie6.css', 'ie7.css']

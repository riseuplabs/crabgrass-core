#
# All the magic directory constants should live here.
#

# config

CRABGRASS_CONFIG_DIRECTORY = "#{Rails.root}/config/crabgrass"
CRABGRASS_SECRET_FILE      = "#{CRABGRASS_CONFIG_DIRECTORY}/secret.txt"

# extensions

EXTENSION_DIRECTORY       = "#{Rails.root}/extensions"
THEMES_DIRECTORY          = "#{EXTENSION_DIRECTORY}/themes"
SEARCH_FILTERS_DIRECTORY  = "#{EXTENSION_DIRECTORY}/search_filters"

# plugins

MODS_DIRECTORY              = "#{EXTENSION_DIRECTORY}/mods"
PAGES_DIRECTORY             = "#{EXTENSION_DIRECTORY}/pages"
CRABGRASS_PLUGINS_DIRECTORY = "#{Rails.root}/vendor/crabgrass_plugins"

# tmp

TMP_DIRECTORY = "#{Rails.root}/tmp"
CACHE_DIRECTORY = "#{TMP_DIRECTORY}/cache"

# assets

if Rails.env == 'test'
  ASSET_PRIVATE_STORAGE = "#{Rails.root}/tmp/private_assets"
  ASSET_PUBLIC_STORAGE  = "#{Rails.root}/tmp/public_assets"
  KEYRING_STORAGE       = "#{Rails.root}/tmp/private_assets/keyrings"
else
  ASSET_PRIVATE_STORAGE = "#{Rails.root}/assets"
  ASSET_PUBLIC_STORAGE  = "#{Rails.root}/public/assets"
  KEYRING_STORAGE       = "#{Rails.root}/assets/keyrings"
end


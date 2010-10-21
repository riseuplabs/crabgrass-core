# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_crabgrass-core_session',
  :secret      => '7013ff2fc31f8c25d77de378c631f2fcedc15a510417b3070d17806089fcd6213fc319dd601c834efcdf1dc2eaa1314c0ec44fad991b23e8daa20fb234e4f3c5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

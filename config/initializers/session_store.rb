# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trademark-search_session',
  :secret      => '2eb2b776946b4e00b0b5073077938fbc861c4c92da912a7e066119065d340964575f1f786608b90a202c4b9ba512f8d813321e41db1d27fffe41903fa4c3dab1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

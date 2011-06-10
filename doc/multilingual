Multilingual Support in Crabgrass
=======================================

Get multi-byte character encoding to work
-----------------------------------------------

In order to store multibyte unicode, run this:

  rake cg:convert_to_unicode RAILS_ENV=production

Now you should be able to store arabic, chinese, hebrew, etc.
This task only works with mysql. You should only have to do this once.

Enable Localized User Interface
------------------------------------

All crabgrass localizations are stored in RAILS_ROOT/config/locales/*.yml. The
name of the file is the code of the language. These localizations
will not appear for the user until they are enabled in the database.


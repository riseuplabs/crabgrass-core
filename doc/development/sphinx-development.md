Sphinx Development
===============================

There are some important rake tasks for sphinx testing and development.

To install sphinx:

    apt-get install sphinxsearch

Configuring Sphinx
--------------------------------------

Edit `config/sphinx.yml` to change any options you need to.

To test to see if sphinx is installed and working, you can try to build the
config file. Generally, this is done for you, but it is good for testing:

  rake ts:config

If you don't get any errors, then things are probably working.

Running sphinx tests
------------------------------------

The page_terms fixtures are auto-generated, but they need to be re-generated
when anything changes how page_terms objects are saved.

    rake cg:test:update_fixtures

To get sphinx tests running:

    rake RAILS_ENV=test db:test:prepare db:fixtures:load ts:index ts:start

What does this do?

* db:test:prepare - make sure the test db schema is the same as development
* db:fixtures:load - reload all the fixtures (might have changed if page terms changed)
* ts:index - generate the sphinx index
* ts:start - start the background sphinx search daemon (searchd)

Also, you have new migrations, you will need to do a `rake db:schema:dump` so
that db:test:prepare will load the right schema.

Sphinx in development mode
----------------------------------------

Same deal:

    rake cg:test:update_fixtures db:fixtures:load ts:index ts:start

Sphinx in production mode
---------------------------------------------

Mostly, to do the same steps to start out:

    rake RAILS_ENV=production ts:confix ts:index ts:start

Crabgrass uses delta indexes. This makes it faster to get new changes in the database,
but only so long as the delta index is small. So, you need to clear out the delta index
by reindexing all the records on a regular basis:

Set up a cron job to do this nightly:

    cd /usr/apps/crabgrass/current && rake ts:index RAILS_ENV=production

NOTE: this should be done automatically for you if you have installed the crabgrass cronjob.

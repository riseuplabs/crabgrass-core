1. [Install for development](#install-for-development)
2. [Install for testing](#install-for-testing)
3. [Install for production](#install-for-production)
4. [Configuration options](#configuration-options)

Install for development
====================================================

Install basic ruby environment (at least ruby 1.9.3, ideally ruby 2.1)

On a debian-based system:

    sudo apt-get install ruby ruby-dev rake mysql-server
    mysql-client libmysqld-dev git make libssl-dev g++ sphinxsearch

Depending on what you are running, you might need to install `git-core`
instead of `git`. You might also need libopenssl-ruby.
If installing using bundler, you may need `libmysqlclient-dev` and `libsqlite3-dev`.

On a redhat-based system:

    yum install ruby ruby-devel rubygem-rake mysql-server mysql-devel git gcc make

Checkout the codebase

    git clone ssh://git@github.com/riseuplabs/crabgrass-core.git
    or
    git clone https://github.com/riseuplabs/crabgrass-core.git

Alternately, do a shallow clone. This will only check out a copy of the most recent version.

    git clone --depth 1 https://github.com/riseuplabs/crabgrass-core.git

Install bundler (as root)

    sudo gem install bundler

Alternatively you can install bundler with your package manager.

Install rails and required gems

    cd crabgrass-core
    bundle install

Create a secret

    rake create_a_secret

Create the database:

    cp config/database.yml.example config/database.yml
    rake db:create
    rake db:schema:load
    rake db:fixtures:load

You might have to adjust config/database.yml according to your mysql setup.

Install helper applications:

On Debian / Ubuntu:

    sudo apt-get install graphicsmagick

On RHEL/CentOS:

    yum install ImageMagick

Run server:

    BOOST=1 bundle exec rails server thin

Connect to the web application from your browser:

    http://localhost:3000
    login: blue
    password: blue

The first request will be slow because the server compiles the stylesheets  for the themes.
See doc/development/* for more notes on development.

Install for testing
====================================================

Install additional gems needed for testing:

    sudo RAILS_ENV=test rake gems:install

Create testing database:

    sudo mysqladmin create crabgrass_test
    cd crabgrass-core
    rake db:test:prepare

Run tests:

    bundle exec rake

Install for production
====================================================

setup the environment
---------------------

Many of the following commands require RAILS_ENV to be set. You can do so
for the current session with
    export RAILS_ENV=production

You may also want to add this to your shell environment by default.

Alternatively you can prefix the commands involving rails or rake like this

    RAILS_ENV=production bundle exec rails c

install prerequisites
----------------------

Download and install ruby, rubygems, rails, and mysql the same way as
in the 'install for development' instructions.

Then:

    apt-get install sphinxsearch
    bundle install

`sphinxsearch` is not technically required, but crabgrass runs 100 times faster
with it installed.

setup the database
----------------------

create the database:

    sudo mysqladmin create crabgrass

create database.yml:

    cp config/database.yml.example config/database.yml

edit config/database.yml:

    username: crabgrass
    password: your_password

set the permissions:

    > mysql --user root -p
    mysql> use crabgrass;
    mysql> grant all on crabgrass.* to crabgrass@localhost identified by 'your_password';
    mysql> flush privileges;
    mysql> quit

initialize the database:

    rake cg:convert_to_unicode
    rake db:schema:load

A note about unicode support: running `rake db:create` does not correctly create a
fully unicode compatible database. To make non-latin languages work, you need the
`rake cg:convert_to_unicode` task. It only needs to be run once, but is
non-destructive, so it can be run anytime.

compile assets
-----------------------

There are some static assets that need to be compiled in production mode.
This should be run after deploying a new version of the codebase:

    rake cg:compile_assets

configure apache
-----------------------

See doc/deployment/apache for information on deploying for production with apache.

set up crontab
-----------------------

There are a bunch of maintenance tasks that need to be updated regularly. The
easiest way to do this is to set up a crontab. The gem `whatever` will install
one for you from the schedule.rb config file.

    whenever --update-crontab -f config/misc/schedule.rb

start delayed job daemon
--------------------

We index updated documents in sphinx using delayed job.
(ts-delayed-delta to be exact).
Run delayed job as a daemon so it can start the jobs:

    script/delayed_job start

You may want to symlink script/delayed_job from your start script directory
such as /etc/init.d

Configuration options
====================================================

All the options that you might want to change live in three places:

1. config/database.yml
2. config/secret.txt
3. config/crabgrass/crabgrass-<mode>.yml.

See config/crabgrass/README for more information.

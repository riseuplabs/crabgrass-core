= Some tips for debugging in crabgrass

== General Testing Tips

You can run a single test at a time like so:

  ruby -I test test/unit/user_test.rb --name test_user_name

When you use 'rdebug' instead of 'ruby' you can put 'debugger'
lines in you code and it will stop on the line.

You can replace --name with -n


== Using INFO environment variable

sometimes, it is much more useful to use print for debugging than
to step through with a debugger.

to enable the printing of the 'info()' messages, define the INFO
environment variable:

  INFO=1 ruby test/unit/user_test.rb

  INFO=0 rake test:units

  INFO=3 script/server

The info level determines how much is shown:

  0 -- only high level stuff
  1 -- more detail
  2 -- even more detail
       and so on...
 
== Stopping on a SQL query

have you ever wanted to know what part of your code was triggering a particular
sql query? set the STOP_ON_SQL environment variable to find out.

For example:

  export STOP_ON_SQL='SELECT * FROM `users` WHERE (`users`.`id` = 633)'
  script/server -u

This will drop you into the debugger whenever that query occurs.

== Printing Logs to STDOUT

Sometimes while running tests, it is useful to see what SQL is being executed
by different tests. You can do this by redirecting the logs to STDOUT by setting
this environment variable:

  SHOWLOGS=1 ruby test/unit/person_test.rb

This is also useful with script/console.

== Debugging View Tests

You can use the method "response_body" to get an easier to read version of the
response body. Super useful!

== Debugging Routes

in the console:
  include ActionController::UrlWriter
  default_url_options[:host] = 'localhost'

via rake:
  rake routes

== Debugging ActiveRecord Callbacks

Set the ENV variable DEBUG_CALLBACKS=1 to trace the execution of activerecord
callbacks

== Showing the call stack

This is not specific to crabgrass, but it is hard to find much mention of this
on the 'net: you can print out a trace of the call stack by doing this in your
code:
  
  puts caller

Thats it. Handy.


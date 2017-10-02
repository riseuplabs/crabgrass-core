= Some tips for writing tests

Crabgrass is a long running project and our approaches to testing have
changed just as much as our coding style accross other parts of the
projects. This document is trying to give you an idea of what we are
aiming at. You will find tests that do not match it. Feel free to
improve them. :)

== Focus on what you want to test

Try to write tests that focus on one piece of functionality each. Each
test should setup it's requirements, run the code that is under test and
then assert the results. It's okay to combine a few assertions that are
related such as testing the response code and the body.

== Integration Tests

We have high level integration tests to save clicking through the
application to see if everything works. They are a good starting point
for writing new features or reproducing bugs.

== Testing Controllers

Controller tests are the next step in isolating the problem / testing
the feature. They should run one http request and make assertions on the
response. Please don't run multiple requests from the same test but
split the test in separate ones. If you need to create some data
structures either use fixtures or FactoryGirl or call functions on the
models themselves.

Try to avoid complex controllers so that you can still cover the main
code paths with a few tests per action.

== Testing Models and Logic

Unit tests accompany writing or refactoring the models. If have a bunch
of functions that work together try testing them seperately. This way
you only have to test a few code paths for each function and the overall
complexity broken down into little pieces on the testing side as well.
Also you will know a lot better what is broken if a test fails and tests
will run a lot faster.

We have an almost complete set of tests for the models. However most of
these are not really well isolated. If you work on testing the models
please try to further isolate the tests.

Try to split models into logical units that you can easily test. Please
test the public interface of them rather than internals. If you want to
test logic that is hidden from the controller - isolate it into a
separate model and test that model. Models do not need to be backed by a
database record.

Let me give you an example. You want to test the notification that lets
your friends know you joined a group. We currently test this by creating
a few users, making them friends, creating a group, adding one user to
the group and making assertions on the activity created. This test takes
quite some time and it will break if any of the steps break. Instead
it's beter to
* make sure the after create callback gets called on creating the
  membership
* test the callback creates the proper activities with stub users and
  groups
* test activities are properly displayed for your friends

All these should be tested in isolation and it might even make sense to break them down further.

== Fixtures

We're using fixtures mostly for integration tests and functional tests.
Please make sure to always use fixtures for all types of objects you
create. Other objects will not be rolled back by transactional fixtures
and thus remain in the database after your test run. The easiest way to
avoid this is a plain
```
  fixtures :all
```

For unit tests you should be able to create the object under test using
Factory Girl and use stubs and mocks for classes other than the one you
want to test. This way tests are less coupled and database access can be
reduced which will give us faster tests in the long run.

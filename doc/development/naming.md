Naming
======

We used to have quite a few directories added to our `load_path`. This
enabled sorting models by topic (such as 'associations') but it also
meant both rails and you would have to look at a number of places if
you did not know where a class was located. It also brought the risk of
conflicting constants during constant lookup.

Now we're moving towards using namespaces so the class name reflects
it's location directly. This also has quite a few gotchas that are documented
here.

Namespaces
----------

We have a few main models (user, group, page, wiki) and try to put
subordinate models into their namespaces. For example:
 - Wiki::Lock
 - Page::Terms
 - Group::Membership
 - User::Friendship

We also use these namespaces for subclasses (Group::Committee), modules
(User::Cache) and helper classes (Page::Share).

We use the short notation for defining these:
```ruby
class User::Friendship
```
rather than

```ruby
class User
  class Friendship
```

This has a few implications:
 * you don't need to specify wether User is a class or a module
 * Friendship will NOT be registered as a constant in the User namespace
 * one level of indention

[how constant lookup works in ruby](https://cirw.in/blog/constant-lookup)

So even within the User::Cache and User itself you will still have to use
User::Friendship. This has the benefit of pointing the reader directly to the
corresponding file.

### Avoid Conficts

Ruby constant loading does a few unexpected things. In particular when asking
for User::Cache it will check if the constant Cache is defined in User. If it
is not it will look for Cache in the global namespace. If that constant exists
it will print a warning but happily use it never the less. Usually this is not
what we want.

You can work around this issue by making sure the nested constant is loaded
whenever it is accessed (by using `require` or `require_dependency`). However
it's nice to be able to rely on rails for autoloading.

So beware of reusing toplevel constants in namespaces and the other way round.
In order to help with this we use singular words for toplevel constants (User)
and plural form for nested constants that might conflict (Group::Users).

Naming Models
--------------------------

We moved code from models into modules quite a bit (concerns). Lately i've
tried to use composition instead. So we have a mixture of different things
in the model directories.
In order to indicate what a file is about let's try to stick to a naming
scheme:
* Record classes, subclasses and substitudes have a singular noun as the name:
  User::Token, User::Ghost, User::Stranger
* Helper Classes use a verb or a noun based on a verb
  User::Finder, Page::Share
* Concerns that provide associations and related methods use the plural of
  the associated class:
  User::Groups, User::Users
* Concerns that provide other things than associations use participles:
  User::Caching, User::Authenticated

Sometimes it's not obvious what a word is (rating, setting, cache).
We'll have to live with that. In general these are recommendations and you
will find we are not following them everywhere yet.

Tables
------

Rails default behaviour for nested modules is a bit confusing at first.
It ignores the module namespaces but adds prefixes for class namespaces.
So `Wiki::Lock` will look at the `wiki_locks` table if `Wiki` is a class.
If `Wiki` is a module it will look at the `locks` table.

Many table names are still based on what we used to have. In order to get
them to work we set `self.table_name` in the first line of the model.

If you get to pick a new table one or change one we prefer the prefixed
version. It's okay to keep the short one if the name is specific enough.
So instead of `tokens` we probably should have used `user_tokens` or even
`user_recovery_tokens` but `memberships` seems fine.

Fixtures
--------

In general fixtures need to be named like the corresponding table. However
`/` will be converted to `_`. This works nicely with the prefixed naming
scheme for nested classes: `Page::AccessCode` will use the `page_access_code`
table and fixtures in `page/access_code` will also map to the class.
Otherwise you have to specify the class in the `test_helper` with
`set_fixture_class`.

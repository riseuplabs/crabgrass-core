0.6.2
======

0.6 is the current series. It mainly consists of the core rewrite that braught two streams of development back together.

bugfixes
--------

0.6.2 will follow up on bugs reported during the testing phase of the new core rework

These bugs were listed in the development notes: They need to be confirmed and evtl. fixed:
* deleting a page tag causes the discussions to get loaded for the ajax request.
  this should not be the case.
* i18n blows up if the session language is set to swedish.
* page search:
  ** should be 'watching' instead of 'watched'
  ** once active, needs to indicate i clicked on 'my pages -> own'.
  ** need ajaxy history
* when notices are rendered as pages, they still fade.
* alert messages don't stack for modalbox
* pages need 'show print' option.
* new page creation tab is 'show' should be 'edit'
* grouphome: summary links break left column formatting
* remove details from page feeds for now
* banner width problems: https://labs.riseup.net/code/issues/4360
* gallery > show formatting problems
* tasklist text doesnt line up with checkboxes
* survey page formatting and error message: https://labs.riseup.net/code/issues/4362
* wiki:
  ** versioning is a mess
  ** full page edit form is too narrow
  ** trying to open multiple sections for editing isnt working (see issue)

main regressions to fix
-----------------------

wiki:
  need history


minor features
--------------

* confirmation before destroy contact
* the split panel is not something that we should keep, unless it can
  be made to work when the screen gets small.

log evaluation
--------------

We'll keep a close eye on the logs during the test phase in order to:
* look for crashes and fix them
* look for speedup possibilities
* track invalid records and fix them and their causes


0.7.0
==========

0.7 is the next round of development. This is likely to take place in Summer 2015. It's focus will be further catching up with the development of our dependencies and bugfixes and bringing back features after the core rework. It will also include work for 'data ecology' - cleaning up outdated records and improving the deletion of groups and users.

Upgrade dependencies
-----

* rails 4.2
* write new plugin system as the old one is not supported by rails 4 anymore
* ruby 2.x
* Thinking sphinx and sphinx

Search improvements
-------------------

* new thinking sphinx
* better fields for sphinx
* get rid of page_terms


destroying groups
-----------------

needs a lot of work
What to do with orphaned pages?
All the pages that have cached the owner_name should get cleared out.
    (or maybe not, instead link to 'anonymous'?)
What about everywhere else? create GroupGhost with the same id but with no content?
Is expelling from Group with a request working?

directory improvements
---------------------

* display more interesting content
* allow to filter by more criteria
* allow groups to promote themselves (and people to promote groups)

permission clearity
-------------------

Groups should be closed by default. Users can decide to publish it then.
Clearly show if a page or a group is publicly visible

remote processing
--------------------

* what happens when we do remote_job.destroy?
* what happens to the background thread on the cg-processor doing the work?
* what happens to the files it spits out?


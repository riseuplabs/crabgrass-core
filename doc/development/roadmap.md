0.6.2
======

0.6 is the current series. It mainly consists of the core rewrite that braught two streams of development back together.
0.6.2 contains all the fixes that need to be applied before going live with the new server.

bugfixes
--------

0.6.2 will follow up on bugs reported during the testing phase of the new core rework

log evaluation
--------------

We'll keep a close eye on the logs during the test phase in order to:
* look for crashes and fix them
* look for speedup possibilities
* track invalid records and fix them and their causes

permission fixes
----------------

* ensure committees of hidden groups are hidden.


0.6.3
=====

0.6.3 contains fixes for issues found after going live with the new server. We'll also target some issues that were tabled for 0.6.2

These bugs were listed in the development notes:

confirmed:
* pages other than wiki need 'show print' option

unclear:
* alert messages don't stack for modalbox
  ** azul> where is this needed? 
     I was able to confirm in the share page modal. If you try two names that do
     not exist only the latter will replace the former - which makes sense.
* when notices are rendered as pages, they still fade.
  ** azul> ???
* grouphome: summary links break left column formatting
  ** azul> have not been able to reproduce this
* remove details from page feeds for now
  ** azul> I think they are gone. Are they?

performance tweaks:
* deleting a page tag causes the discussions to get loaded for the ajax request.
  this should not be the case.

main regressions to fix
-----------------------

wiki:
  need history functions (diff, delete version, restore)


minor features
--------------

* confirmation before destroy contact
* page search:
  ** should include 'watching' filter (used to be 'watched' - is gone right now)
* the split panel is not something that we should keep, unless it can
  be made to work when the screen gets small.
* allow opening multiple sections for editing (see issue)


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


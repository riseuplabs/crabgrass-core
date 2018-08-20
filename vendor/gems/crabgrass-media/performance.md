Conversion Performance
======================

Convert to pdf
--------------

Some converters take ages - in particular for large documents.

Here's a few measurements for:

a) libreoffice --headless from cg
b) unoconv
c) unoconv with server running
d) unoconv with PageRange=1-1
e) unoconv with PageRange=1-1 and server running


Single page odt to pdf:
a) 0.70 sec
b) 1.46 sec
c) 0.49 sec
d) 1.47 sec
e) 0.48 sec


200 page odt to pdf:
a) 13.63 sec
b) 14.21 sec
c) 13.27 sec
d)  7.01 sec
e)  6.17 sec


Order of conversions
--------------------

The first thing we need after an upload is a small thumbnail. Unfortunately
this is also the thing that takes most steps to generate:

* doc   -> pdf
* pdf   -> large jpg
* large -> small jpg

We could skip the large jpg, but we need it anyway. Also the large to small jpg
step usually is the fastest.
So instead we do:

1. doc        -> 1 page pdf
2. 1 page pdf -> large jpg
3. large jpg  -> small jpg
4. large jpg  -> medium jpg
5. doc        -> full pdf
6. doc        -> full odt

* doc -> x conversion cannot run in parellel. So we will want higher
  priority for the first step.
* We can use a different delayed job queue for the image conversions.
* The jpg -> jpg conversion could even happen in process if needed.

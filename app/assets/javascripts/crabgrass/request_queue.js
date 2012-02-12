//
// RequestQueue does two things:
// 
// (1) Allows you to make a bunch of ajax requests all at once, but have them
//     queue up. The next one is sent once there are no more pending ajax requests.
//
// (2) Parameters are eval'ed when the request is actually fired off,
//     not when it is queued.
//
// Otherwise, it is used like a typical prototypejs Ajax.Request.
//
// For example:
//
//    << write an example >>
//

var RequestQueue = {

  //
  // adds a new request to the queue.
  //
  add: function(url, options, parameters) {
    this.queue = this.queue || []
    this.queue.push({url:url, options:options, parameters:parameters});
    if (!this.timer) {
      this.timer = setInterval("RequestQueue.poll()", 100)
    }
  },

  //
  // If there are no current pending requests, send the next one on the stack.
  //
  poll: function() {
    if (Ajax.activeRequestCount == 0) {
      var req = this.queue.pop();
      if (req) {
        if (req.parameters) {req.options.parameters = eval(req.parameters)}
        new Ajax.Request(req.url, req.options);
      } else {
        clearInterval(this.timer);
        this.timer = false;
      }
    }
  }
}

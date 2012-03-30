//
// Busy cursor
//
// When a ajax request is pending, this will change the cursor to be a busy cursor.
// It depends on this css:
//
// html.busy, html.busy * {  
//   cursor: wait !important;  
// }  
//
// source: http://postpostmodern.com/instructional/global-ajax-cursor-change/
//
// NOTE: currently disabled. This is really cool, but some ajax queries
// cause activeRequestCount to keep incrementing. Until that is fixed,
// this must be disabled.
//

// in prototype:
// Ajax.Responders.register({
//   onCreate: function() {
//     if (Ajax.activeRequestCount > 0) {
//       $$('html')[0].addClassName('busy');
//     }
//   },
//   onComplete: function() {
//     console.log("Ajax.activeRequestCount " + Ajax.activeRequestCount);
//     if (Ajax.activeRequestCount == 0) {
//       $$('html')[0].removeClassName('busy');
//     }
//   }
// }); 

// in jquery:
// function globalAjaxCursorChange() {
//   $("html").bind("ajaxStart", function() {
//      $(this).addClass('busy');
//    }).bind("ajaxStop", function() {
//      $(this).removeClass('busy');
//    });
// }
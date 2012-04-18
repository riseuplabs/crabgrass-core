// //
// // crabgrass pushState history support.
// //

// History.Adapter.bind(window,'statechange',function() {
//   var state = History.getState();
//   console.log('history state change: ' + JSON.stringify({url:state.url, data:state.data}))
//   if (state.data) {
//     process_history_state_change(state);
//   }
// });

// function process_history_state_change(state) {
//   var data = state.data;

//   //
//   // update a dom element with an ajax request
//   //
//   if (data.update && $(data.update.domid)) {
//     new Ajax.Updater(data.update.domid, data.update.path, {
//       asynchronous:true, evalScripts:true, method:'get'
//       //parameters: 'authenticity_token=' + encodeURIComponent(data.token)
//     });
//   }

//   //
//   // hide and show a dom element
//   //
//   //if (data.hide && $(data.hide)) { $(data.hide).hide(); }
//   //if (data.show && $(data.show)) { $(data.show).show(); }

//   //
//   // slide an dom element around
//   //
//   if (data.slide_left && $(data.slide_left)) {
//     new Effect.MoveByPercent(data.slide_left, {duration: 0.5, x:-100});
//   }
//   if (data.slide_right && $(data.slide_right)) {
//     new Effect.MoveByPercent(data.slide_right, {duration: 0.5, x:100});
//   }
// }

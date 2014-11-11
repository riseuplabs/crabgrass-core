//
// AUTOCOMPLETE
//

function cgAutocompleteEntities(id, url, opts) {
   var random_id = Math.floor(Math.random() * 1000000000);
   var options = {serviceUrl:url, minChars:2, maxHeight:400, width:300, onSelect: null, message: '', container: '', preloadedOnTop: true, rowRenderer: autoCompleteRowRenderer, selectValue: autoCompleteSelectValue};
   if (opts) {
     if (opts.message)   {options.message   = opts.message}
     if (opts.container) {options.container = opts.container}
     if (opts.onSelect)  {options.onSelect  = opts.onSelect}
   }
   new Autocomplete(id, options, random_id);
}

function autoCompleteRowRenderer(value, re, data) {
  return "<p class='icon xsmall' style='background-image: url(/avatars/" + data + "/xsmall.jpg)'>" + value.replace(/^<em>(.*)<\/em>(<br\/>(.*))?$/gi, function(m, m1, m2, m3){return "<em>" + Autocomplete.highlight(m1,re) + "</em>" + (m3 ? "<br/>" + Autocomplete.highlight(m3, re) : "")}) + "</p>";
}

function autoCompleteSelectValue(value){
  return value.replace(/<em>(.*)<\/em>.*/g,'$1');
}

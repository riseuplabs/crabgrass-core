module LayoutHelper
  ##
  ## JAVASCRIPT
  ##

  # Core js that we always need.
  # Currently, effects.js and controls.js are required for autocomplete.js.
  # However, autocomplete uses very little of the controls.js code, which in turn
  # should not need the effects.js at all. So, with a little effort, effects and
  # controls could be moved to extra.
  MAIN_JS = {:main => ['prototype', 'application', 'modalbox', 'effects', 'controls', 'autocomplete']}

  # extra js that we might sometimes need
  EXTRA_JS = {:extra => ['dragdrop', 'builder', 'slider']}

  # needed whenever we want controls for editing a wiki
  WIKI_JS = {:wiki => ['wiki/html_editor', 'wiki/textile_editor', 'wiki/wiki_editing', 'wiki/xinha/XinhaCore']}

  JS_BUNDLES = [MAIN_JS, EXTRA_JS, WIKI_JS]

  JS_BUNDLE_LOAD_ORDER = JS_BUNDLES.collect{|b|b.keys.first}

  # eg: {:main => [...], :extra => [...]}
  JS_BUNDLES_COMBINED = JS_BUNDLES.inject({}){|a,b|a.merge(b)}

  # eg: {'dragdrop' => :extra, 'modalbox' => :main, ...}
  JS_BUNDLE_MAP = Hash[*JS_BUNDLES_COMBINED.collect{|k,v|v.collect{|u|[u,k]}}.flatten]


end

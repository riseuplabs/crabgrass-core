#
# override how validation errors are drawn
# http://getbootstrap.com/css/#forms-control-validation
#
ActionView::Base.field_error_proc = proc do |html_tag, _instance_tag|
  %(<div class="has-error">#{html_tag}</div>).html_safe
end

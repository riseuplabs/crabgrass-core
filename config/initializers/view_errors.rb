#
# override how validation errors are drawn
# http://getbootstrap.com/css/#forms-control-validation
#
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  %Q(<div class="has-error">#{html_tag}</div>).html_safe
end

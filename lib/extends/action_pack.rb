require 'rubygems'
require 'action_pack'
require 'action_view'
require 'action_controller'

###
### MULTIPLE SUBMIT BUTTONS
###

# It is nice to be able to have multiple submit buttons.  For non-ajax, this
# works fine: you just check the existance in the params of the :name of the
# submit button. For ajax, this breaks, and is labelled wontfix
# (http://dev.rubyonrails.org/ticket/3231). This hack is an attempt to get
# around the limitation. By disabling the other submit buttons we ensure that
# only the submit button that was pressed contributes to the request params.

class ActionView::Base

  alias rails_submit_tag submit_tag
  def submit_tag(value = 'Save changes', options = {})
    # disable buttons on submit by default
    options[:data] ||= {}
    options[:data].reverse_merge! disable_with: value
    rails_submit_tag(value, options)
  end
end

###
### LINK_TO FOR COMMITTEES
###

# I really want to be able to use link_to(:id => 'group+name') and not have
# it replace '+' with some ugly '%2B' character.

module LinkToWithPrettyPlusSigns

  def link(*args)
    link = method(:link).super_method.call(type_name)
    if link.html_safe?
      link.sub('%2B', '+').html_safe
    else
      link.sub('%2B', '+')
    end
  end
end

class ActionView::Base
  prepend LinkToWithPrettyPlusSigns  
end


###
### CUSTOM FORM ERROR FIELDS
###

# Rails form helpers are brutal when it comes to generating
# error markup for fields that fail validation
# they will surround every input with .fieldWithErrors divs
# and will mess up your layout. but there is a way to customize them
# http://pivotallabs.com/users/frmorio/blog/articles/267-applying-different-error-display-styles

# class ActionView::Base
#  def with_error_proc(error_proc)
#    pre = ActionView::Base.field_error_proc
#    ActionView::Base.field_error_proc = error_proc
#    yield
#    ActionView::Base.field_error_proc = pre
#  end
# end

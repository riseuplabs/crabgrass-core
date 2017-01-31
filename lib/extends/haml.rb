require 'haml/buffer'

#
# Haml has it's own way of creating object references.
# They are similar but not the same as in rails' dom_id
#
# haml: post_1, post_new, edit_post_1, edit_post_new
# rails: post_1, new_post, edit_post_1, edit_new_post
#
# Let's always use the rails version to make sure they are the same.
#

class Haml::Buffer
  include ActionView::RecordIdentifier

  def parse_object_ref(array)
    {'id' => dom_id(*array), 'class' => dom_class(*array)}
  end

end

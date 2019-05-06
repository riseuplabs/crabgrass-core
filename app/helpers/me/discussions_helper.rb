module Me::DiscussionsHelper
  def post_summary_body(post)
    caption = if post.created_by == current_user
                I18n.t(:message_you_wrote_caption)
              else
                I18n.t(:message_user_wrote_caption, user: post.created_by.try.display_name)
    end

    preview = strip_tags(post.body_html).truncate(300).html_safe
    content_tag(:em, caption, class: 'author_caption') + " \n" +
      content_tag(:span, preview, class: 'post_body')
  end

  def send_message_function(default_recipient_name = nil)
    submit_url = me_discussion_posts_path('__ID__')
    "submitNestedResourceForm('recipient_name', '#{submit_url}', #{default_recipient_name.blank?})"
  end

end

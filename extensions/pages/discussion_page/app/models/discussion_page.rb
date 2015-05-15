class DiscussionPage < Page #:nodoc:

  # limit comments to people who can edit
  def comment_access
    :edit
  end

  # indexing hooks

  # comments are the body of this page
  alias_method :body_terms, :comment_terms
  
  def comment_terms
    ""
  end

end


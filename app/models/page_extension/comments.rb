#
# Page relationship to comments
#
# Comments are of type Post, owned by a Discussion.
# Page owns a single Discussion.
#
# TODO: give page a discussion_id instead of putting the page_id in discussions table.
# 
module PageExtension::Comments

  def self.included(base)
    base.instance_eval do
      has_one :discussion, :dependent => :destroy
      validates_associated :discussion
    end
  end

  public

  def posts(options={})
    return [] unless self.discussion
    options = {:order => "created_at ASC", :per_page => Site.current.pagination_size, :include => :ratings}.merge(options)
    options[:page] ||= discussion.last_page # for now, always paginate.
    if options[:page]
      Post.visible.paginate_by_discussion_id(discussion.id, options)
    else
      Post.visible.find_by_discussion_id(discussion.id, options)
    end
  end

  #
  # use Post.create! instead.
  #
  #def build_post(post,user)
  #  # this looks like overkill, but it seems to be needed
  #  # in order to build the post in memory and have it saved when
  #  # (possibly new) pages is saved
  #  self.discussion ||= Discussion.new
  #  self.discussion.page = self
  #  if post.instance_of? String
  #    post = Post.new(:body => post)
  #  end
  #  self.discussion.posts << post
  #  post.discussion = self.discussion
  #  post.user = user
  #  post.page_terms = self.page_terms
  #  association_will_change(:posts)
  #  return post
  #end

  protected

  # handled by discussion now...
  #def update_posts_count
  #  if posts_count_changed? # trigger by post.rb, page.post_count_will_change!
  #    self.posts_count = self.discussion.posts_count if self.discussion
  #  end
  #end

end

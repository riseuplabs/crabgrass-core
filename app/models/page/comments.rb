#
# Page relationship to comments
#
# Comments are of type Post, owned by a Discussion.
# Page owns a single Discussion.
#
module Page::Comments

  def self.included(base)
    base.instance_eval do
      has_one :discussion, dependent: :destroy
      validates_associated :discussion
    end
  end

  public

  def posts(pagination_options={})
    return [] unless self.discussion
    pagination_options[:per_page] ||= Conf.pagination_size
    pagination_options[:page] ||= discussion.last_page
    self.discussion.posts.includes(:user).paginate(pagination_options)
  end

  def add_post(user, post_attributes)
    Post.create!(self, user, post_attributes).tap do
      user.updated(self)
      save
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

end

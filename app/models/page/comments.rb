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

  def posts(pagination_options = {})
    return [] unless discussion
    pagination_options[:per_page] ||= Conf.pagination_size
    pagination_options[:page] ||= discussion.last_page
    discussion.posts.includes(:user).paginate(pagination_options)
  end

  def add_post(user, post_attributes)
    Post.create!(self, user, post_attributes.to_h).tap do
      user.updated(self)
      save
    end
  end

end

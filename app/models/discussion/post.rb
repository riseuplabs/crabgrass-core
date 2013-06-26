#  create_table "posts", :force => true do |t|
#    t.integer  "user_id",       :limit => 11
#    t.integer  "discussion_id", :limit => 11
#    t.text     "body"
#    t.text     "body_html"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.datetime "deleted_at"
#    t.string   "type"
#  end

class Post < ActiveRecord::Base

  ##
  ## ASSOCIATIONS
  ##

  acts_as_rateable
  belongs_to :discussion    # counter_cache is handled manually, see Discussion.post_created.
  belongs_to :user
  belongs_to :page_terms    # if this is on a page we set page_terms so we can use path_finder

  attr_accessible :user, :discussion, :body, :page_terms_id

  after_create :post_created
  after_destroy :post_destroyed

  ##
  ## FINDERS
  ##

  acts_as_path_findable

  scope :visible, :conditions => 'deleted_at IS NULL'

  scope :by_created_at, :order => 'created_at DESC'

  ##
  ## ATTIBUTES
  ##

  format_attribute :body
  validates_presence_of :user, :body

  alias :created_by :user

  attr_accessor :in_reply_to    # the post this post was in reply to.
                                # it is tmp var used when post activities.

  attr_accessor :recipient      # for private posts, a tmp var to store who
                                # this post is being sent to. used by activities.

  ##
  ## METHODS
  ##

  # build a new post in memory, setting up the associations which need to be in
  # place, but don't save anything yet (however, if the page doesn't have a
  # discussion record yet, then it is created and saved). Arg is a hash, with
  # these required keys: :user, :page, and :body. Afterwards, you must save the
  # post, and the probably the page too, although it is not required.
  # In a non-page context, this method is not needed. simply calling
  # discussion.posts.build() is sufficient.
  # def self.build(options)
  #   raise ArgumentError.new unless options[:user] && options[:page] && options[:body]
  #   page = options.delete(:page)
  #   page.discussion ||= Discussion.create!(:page => page)
  #   post = page.discussion.posts.build(options)
  #   page.posts_count_will_change!
  #   post.page_terms_id = page.page_terms_id
  #   return post
  # end

  #
  # this is like a normal create, except that it optionally accepts multiple arguments:
  #
  # page -- the page that this post belongs to (optional)
  # user -- the user creating the post (optional)
  # discussion -- the discussion holding this post (optional)
  # attributes -- a hash of attributes to fill the new post.
  #
  # You should have at least page or discussion.
  #
  # for example:
  #
  #   Post.create! @page, current_user, params[:post]
  #
  def self.create!(*args, &block)
    user = nil
    page = nil
    discussion = nil
    attributes = {}
    args.each do |arg|
      user       = arg if arg.is_a? User
      page       = arg if arg.is_a? Page
      attributes = arg if arg.is_a? Hash
      discussion = arg if arg.is_a? Discussion
    end
    if page
      page.create_discussion unless page.discussion
      attributes[:discussion] = page.discussion
      attributes[:page_terms_id] = page.page_terms.id
    end
    if discussion
      attributes[:discussion] = discussion
    end
    if user
      attributes[:user] = user
    end
    post = Post.new(attributes, &block)
    post.save!
    return post
  end

  def body_html
    read_attribute(:body_html).try :html_safe
  end

  # used for default context, if present, to set for any embedded links
  def owner_name
    discussion.page.owner_name if discussion.page
  end

  # used for indexing
  def to_s
    "#{user} #{body}"
  end

  # not used anymore
  def editable_by?(user)
    user.id == self.user_id
  end

  def starred_by?(user)
    self.ratings.detect do |rating|
      rating.rating == 1 and rating.user_id == user.id
    end
  end

  # These are currently only used from moderation mod.
  #
  # We implement a similar interface as for pages to ease things there.

  def flow=(value)
    value == FLOW[:deleted] ? self.delete : self.undelete
  end

  def delete
    update_attribute :deleted_at, Time.now
    post_destroyed(true)
  end

  def deleted? ; !!deleted_at ; end

  def deleted_changed? ; deleted_at_changed? ; end

  def undelete
    update_attribute :deleted_at, nil
    post_created
  end

  # this should be able to be handled in the subclasses, but sometimes
  # when you create a new post, the subclass is not set yet.
  def public?
    ['Post', 'PublicPost', 'StatusPost'].include?(read_attribute(:type))
  end
  def private?
    'PrivatePost' == read_attribute(:type)
  end

  def default?
    false
  end

  def lite_html
    GreenCloth.new(self.body, 'page', [:lite_mode]).to_html
  end

  def body_id
   "post_#{self.id}_body"
  end

  protected

  def post_created
    discussion.post_created(self)
  end

  def post_destroyed(force_decrement=false)
    # don't decrement if post is already marked deleted.
    decrement = force_decrement || self.deleted_at.nil?
    discussion.post_destroyed(self, decrement) if discussion
  end

  acts_as_extensible

end


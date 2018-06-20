class Group::HomeController < Group::BaseController
  skip_before_filter :login_required

  before_filter :fetch_wikis
  after_filter :track_visit, if: :logged_in?

  layout 'sidecolumn'
  helper 'wikis/base', 'wikis/sections'

  def initialize(options = {})
    super()
    @group = options[:group]
  end

  def show
    authorize @group
    @pages = Page.paginate_by_path '/descending/updated_at/limit/30/',
                                   options_for_group(@group), pagination_params
  end

  protected

  def fetch_wikis
    @private_wiki = fetch_wiki(:private) if policy(@group).edit?
    @public_wiki = fetch_wiki(:public)
  end

  def fetch_wiki(type)
    @group.profiles.send(type).try.wiki.tap do |wiki|
      return nil if wiki.blank? || wiki.body.blank?
      wiki.last_seen_at = last_visit
    end
  end

  def last_visit
    memberships.pluck(:visited_at).first if logged_in?
  end

  def track_visit
    memberships.update_all(visited_at: Time.now)
  end

  def memberships
    @group.memberships.where(user_id: current_user)
  end

end

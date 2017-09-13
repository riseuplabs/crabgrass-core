class Group::HomeController < Group::BaseController
  skip_before_filter :login_required
  # fetch_group already checks may_show_group?
  skip_before_filter :authorization_required

  before_filter :fetch_wikis
  after_filter :track_visit, if: :logged_in?

  layout 'sidecolumn'
  helper 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'

  def initialize(options = {})
    super()
    @group = options[:group]
  end

  def show
    @pages = Page.paginate_by_path '/descending/updated_at/limit/30/',
                                   options_for_group(@group), pagination_params
    track
  end

  protected

  def fetch_wikis
    @private_wiki = fetch_wiki(:private) if may_edit_group?
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
    memberships.update_all ['total_visits = total_visits + 1, visited_at = ?',
                            Time.now]
  end

  def memberships
    @group.memberships.where(user_id: current_user)
  end

  # helper_method :coming_from_wiki?
  # will return true if we came from the wiki editor, versions or diffs
  # def coming_from_wiki?(wiki)
  #  wiki and params[:wiki_id].to_i == wiki.id
  # end
end

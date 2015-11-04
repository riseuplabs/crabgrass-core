#
# this is a controller for generating a list of entities (users or groups)
# for autocompletion forms.
#
# all the requests are ajax.
#
# TODO: you should be able to control in your permissions if your name shows
# up in someone's recipient list.
#
# TODO: there is a lot of extra logic here to prevent duplicates being sent.
# it might make more sense to have autocomplete js handle duplicates more
# gracefully.
#

class EntitiesController < ApplicationController

  before_filter :login_required

  LIMIT = 20

  def index
    @entities = case params[:view]
      when 'recipients' then recipients
      when 'groups' then groups
      when 'users' then users
      when 'members' then members
      when 'all' then all
      else all
    end
  end

  private

  #
  # all the people in a group, if you are allowed to see them
  #
  def members
    group = Group.find_by_name(params[:group])
    logger.error params[:group]
    if current_user.may?(:see_members, group)
      if preload?
        group.users
      else
        group.users.named_like(filter).limit(LIMIT)
      end
    else
      []
    end
  end

  #
  # people that the current user is allowed to pester
  #
  def recipients
    if preload?
      User.friends_or_peers_of(current_user).all_with_access(current_user => :pester)
    elsif filter.present?
      recipients = User.with_access(current_user => [:view, :pester])
      recipients.named_like(filter).limit(LIMIT)
    end
  end

  #
  # groups
  #
  def groups
    if preload?
      current_user.all_groups
    elsif filter.present?
      visible_groups = Group.with_access(current_user => :view)
      visible_groups.named_like(filter).limit(LIMIT)
    end
  end

  #
  # all users, regardless of relationship
  #
  def users
    if preload?
      # preload user's groups
      User.friends_or_peers_of(current_user).all_with_access(current_user => :view)
    elsif filter.present?
      visible_users = User.with_access(current_user => :view)
      visible_users.named_like(filter).limit(LIMIT)
    end
  end

  def all
    if preload?
      groups + users
    else
      (groups + users).sort_by{|r|r.name}[0..(LIMIT-1)]
    end
  end

  protected

  def filter
    @query = params[:query]
    @query.present? ? "#{params[:query].strip}%" : ""
  end

  # the autocomplete will issues an empty query when first loaded.
  # which gives us an opportunity to early load likely results.
  def preload?
    filter.empty? and logged_in?
  end
end




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

  verify :xhr => true

  LIMIT = 20

  def index
    @entities = case params[:view]
      when 'recipients' then recipients();
      when 'groups' then groups();
      when 'users' then users();
      when 'all' then all();
      else all();
    end
  end

  private

  #
  # people that the current user is allowed to pester
  #
  def recipients
    if preload?
      User.friends_or_peers_of(current_user).access_by(current_user).allows(:pester)
    elsif filter.any?
      recipients = User.on(current_site).strangers_to(current_user)
      recipients = recipients.access_by(:public).allows(:pester)
      recipients.named_like(filter).find(:all, :limit => LIMIT)
    end
  end

  #
  # groups
  #
  def groups
    if preload?
      current_user.all_groups
    elsif filter.any?
      other_groups = Group.without_member(current_user)
      other_groups = other_groups.access_by(:public).allows(:view)
      other_groups.named_like(filter).find :all, :limit => LIMIT
    end
  end

  #
  # all users, regardless of relationship
  #
  def users
    if preload?
      # preload user's groups
      User.friends_or_peers_of(current_user).access_by(current_user).allows(:view)
    elsif filter.any?
      strangers = User.on(current_site).strangers_to(current_user)
      strangers = strangers.access_by(:public).allows(:view)
      strangers.named_like(filter).find(:all, :limit => LIMIT)
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
    @filter ||= begin
      if params[:query].any?
        "#{params[:query]}%"
      else
        ""
      end
    end
  end

  # the autocomplete will issues an empty query when first loaded.
  # which gives us an oppotunity to early load likely results.
  def preload?
    filter.empty? and logged_in?
  end
end




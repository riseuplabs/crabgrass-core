#
# this is a controller for generating a list of entities (users or groups)
# for autocompletion forms.
# 
# all the requests are ajax.
#

class EntitiesController < ApplicationController

  verify :xhr => true

  def index
    @entities = case params[:view]
      when 'recipients' then recipients();
      when 'groups' then groups();
      else recipients();
    end
  end

  private

  #
  # people that the current user is allowed to pester
  #
  def recipients
    if params[:query].empty?
      # preload friends and peers
      User.friends_or_peers_of(current_user)
    else
      # TODO: make this actually work, so something like it:
      # recipients = User.may_be_pestered_by(current_user).name_like(params[:query])
      []
    end
  end

  def groups
    if params[:query].empty? and logged_in?
      # preload user's groups
      current_user.groups
    elsif params[:query].any?
      Group.find :all, :limit => 20, :conditions => ["name LIKE ?", '%' + params[:query]]
    end
  end

end




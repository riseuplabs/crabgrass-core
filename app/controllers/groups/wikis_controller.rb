class Groups::WikisController < Groups::BaseController

  guard :may_edit_group?
  permissions 'wikis'

  def create
    if params[:profile] == 'private'
      @profile = @group.profiles.private
    elsif params[:profile] == 'public'
      @profile = @group.profiles.public
    else
      raise_error 'missing profile parameter'
    end
    wiki = @profile.create_wiki :version => 0, :body => '', :user => current_user
    params[:edit_mode] = 'on'
    index()
  end

  def index
    @private_wiki = @group.private_wiki
    @public_wiki  = @group.public_wiki
    edit_mode     = params[:edit_mode] == 'on' ? true : false
    profile       = params[:profile].present? ? params[:profile] : nil # prevent profile of "", important!

    if edit_mode
      WikiLock.transaction do
        @private_wiki.lock!(:document, current_user) if @private_wiki
        @public_wiki.lock!(:document, current_user)  if @public_wiki
      end
    end
    render :update do |page|
      page.replace 'group_home_wiki_area', :partial => 'groups/home/wikis',
        :locals => {'profile' => profile, 'edit_mode' => edit_mode}
    end
  rescue Wiki::LockedError => @error_message
    render :update do |page|
      page.replace 'group_home_wiki_area', :partial => 'groups/home/wikis',
        :locals => {'profile' => profile, 'edit_mode' => edit_mode, :mode => 'locked'}
    end
  end

end

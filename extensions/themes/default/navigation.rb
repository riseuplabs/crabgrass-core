

define_navigation do

  ##
  ## HOME

  global_section :home do
    label   "Home"
    visible { !logged_in? || controller?(:account, :session, :root) }
    url     '/'
    active  { controller?(:account, :session, :root) }
  end

  ##

  ##
  ## ME
  ##

  global_section :me do
    label "Me"
    visible { logged_in? }
    url     { me_home_path }
    active  { context?(:me) }
    html    :partial => '/layouts/global/nav/me_menu'

    context_section :create_page do
      label  "Create Page"
      url     { new_page_path }
      active  false
      icon    :plus
      visible { @drop_down_menu }
    end

=begin
    context_section :notices do
      label  "Notices"
      url    { me_home_path }
      active { controller?('me/notices') }
      icon   :info
    end
=end

    context_section :pages do
      label  "Pages"
      url    { me_pages_path }
      active { page_controller? }
      icon   :page_white_copy
    end

=begin
    context_section :activities do
      label  "Activities"
      url    { me_activities_path }
      active { controller?('me/activities') }
      icon   :transmit
      local_section :all do
        label  "All Activities"
        url    { me_activities_path }
        active { controller?('me/activities') and params[:view].empty? }
      end
      local_section :my do
        label  "Mine"
        url    { me_activities_path(:view => 'my') }
        active { controller?('me/activities') and params[:view] == 'my' }
      end
      local_section :friends do
        label  "People"
        url    { me_activities_path(:view => 'friends') }
        active { controller?('me/activities') and params[:view] == 'friends' }
      end
      local_section :groups do
        label  "Groups"
        url    { me_activities_path(:view => 'groups') }
        active { controller?('me/activities') and params[:view] == 'groups' }
      end

    end
=end

=begin
    context_section :calendar do
      label  "Calendar"
      url    { me_events_path }
      active { controller?('me/events') }
      icon   :date
    end
=end

    context_section :messages do
      label  "Messages"
      url    { me_discussions_path }
      active { controller?('me/discussions', 'me/posts') }
      icon   :page_message
    end

    context_section :settings do
      label  "Settings"
      url    { me_settings_path }
      active { controller?('me/settings', 'me/permissions', 'me/profile', 'me/requests') }
      icon   :control

      local_section :settings do
        label  "Account Settings"
        url    { me_settings_path }
        active { controller?('me/settings') }
      end

      local_section :permissions do
        label  "Permissions"
        url    { me_permissions_path }
        active { controller?('me/permissions') }
      end

      local_section :profile do
        label  "Profile"
        url    { edit_me_profile_path }
        active { controller?('me/profile') }
      end

      local_section :requests do
        label  "Requests"
        url    { me_requests_path }
        active { controller?('me/requests') }
      end

    end

  end

  ##
  ## PEOPLE
  ##

  global_section :people do 
    label  "People"
    url    :controller => 'people/directory'
    active { controller?('people/') or context?(:user) }
    html    :partial => '/layouts/global/nav/people_menu'

    context_section :no_context do
      visible { context?(:none) }
      active  { context?(:none) }

      local_section :all do
        label "All"
        url { people_directory_path }
        active { params[:path].empty? }
      end

      local_section :friends do
        label "Friends"
        url { people_directory_path(:path => ['friends']) }
        active { params[:path].try.include?('friends') }
      end
    end

    context_section :home do
      label  "Home"
      icon   :house
      url    { entity_path(@user) }
      active { controller?('people/home') }
    end

    context_section :pages do
      label  "Pages"
      icon   :page_white_copy
      url    { person_pages_path(@user) }
      active { page_controller? }
    end

  end

  ##
  ## GROUPS
  ##
 
  global_section :group do
    label  "Groups"
    url    { groups_directory_path }
    active { controller?('groups/') or @group or context?(:group) }
    html    :partial => '/layouts/global/nav/groups_menu'

    context_section :no_context do
      visible { context?(:none) }
      active  { context?(:none) }

      local_section :all do
        label "All"
        url { groups_directory_path }
        active { params[:path].empty? }
      end

      local_section :mygroups do
        label "My Groups"
        url { groups_directory_path(:path => ['my']) }
        active { params[:path].try.include?('my') }
      end
    end

    context_section :home do
      label  "Home"
      icon   :house
      url    { entity_path(@group) }
      active { controller?('groups/home') }
    end

    context_section :pages do
      label  "Pages"
      icon   :page_white_copy
      url    { group_pages_path(@group) }
      active { page_controller? }
    end

    context_section :calendar do
      label  "Calendar"
      url    { group_events_path(@group) }
      active { controller?('groups/events') }
      icon   :date
    end

    context_section :members do
      visible { may_list_memberships? }
      label   "Members"
      icon    :user
      url     { group_members_path(@group) }
      active  { controller?('groups/members', 'groups/invites') }

      local_section :people do
        visible { may_list_memberships? }
        label   { :people.t }
        url     { group_members_path(@group) }
        active  { controller?('groups/members') }
      end

      local_section :groups do
        visible { false }
        label   { :groups.t }
        url     { group_members_path(@group, :view => 'groups') }
        active  { controller?('groups/members') and params[:view] == 'groups' }
      end

      local_section :invites do
        visible { may_create_invite_request? }
        label   { "Send Invites" }
        url     { new_group_invite_path(@group) }
        active  { controller?('groups/invites') && action?('new') }
      end

      local_section :requests do
        visible { may_create_invite_request? }
        label   { 'Membership Requests' }
        url     { group_invites_path(@group) }
        active  { controller?('groups/invites') && !action?('new') }
      end

      #local_section :membership_settings do
      #  visible { may_edit_group? }
      #  label   { 'Membership Settings' }
      #  url     { group_permissions_path(@group, :view => 'membership') }
      #  active  false
      #end

    end

    context_section :settings do
      visible { may_edit_group? }
      label  { :settings.t }
      icon   :control
      url    { group_settings_path(@group) }
      active { controller?('groups/settings', 'groups/requests', 'groups/permissions', 'groups/profile') }

      local_section :settings do
        visible { may_edit_group? }
        label  { :basic_settings.t }
        url    { group_settings_path(@group) }
        active { controller?('groups/settings') }
      end

      local_section :permissions do
        visible { may_edit_group? }
        label  { :permissions.t }
        url    { group_permissions_path(@group) }
        active { controller?('groups/permissions') }
      end

      local_section :profile do
        visible { may_edit_profile? }
        label  { :profile.t }
        url    { edit_group_profile_path(@group) }
        active { controller?('groups/profile') }
      end

      # uncomment this when Settings -> Requests is needed
      #local_section :requests do
      #  visible { may_admin_requests? }
      #  label  { :requests.t }
      #  url    { group_requests_path(@group) }
      #  active { controller?('groups/requests') }
      #end
    end
  end

  ##
  ## GROUPS DIRECTORY
  ##

#  global_section :group_directory do
#    visible { @group.nil? }
#    label  "Groups"
#    url    { groups_directory_path }
#    active { controller?('groups/') }
#    html   :partial => '/layouts/global/nav/groups_menu'
##    section :place do
##    end
##    section :location do
##    end
#  end

end




define_navigation do

  ##
  ## HOME

  # disabled for now
  global_section :home do
    label   { :home.t }
    visible { false } # !logged_in? || controller?(:account, :session, :root) }
    url     '/'
    active  { controller?(:account, :session, :root) }
  end

  ##

  ##
  ## ME
  ##

  global_section :me do
    label   { :me.t }
    # visible { logged_in? }
    url     { logged_in? ? me_home_path : '/' }
    active  { context?(:me) || controller?(:account, :session, :root) }
    html    :partial => '/layouts/global/nav/me_menu'

    context_section :create_page do
      label   { :create_thing.t(:thing => :page.t) }
      url     { new_page_path }
      active  false
      icon    :plus
      visible { @drop_down_menu }
    end

    context_section :notices do
      label  { :my_dashboard.t }
      url    { me_home_path }
      active { controller?('me/notices') }
      icon   :info
    end

    context_section :pages do
      label  { :pages.t }
      url    { me_pages_path }
      active { page_controller? }
      icon   :page_white_copy
    end

#    context_section :activities do
#      label  { :activities.t }
#      url    { me_activities_path }
#      active { controller?('me/activities') }
#      icon   :transmit
#      local_section :all do
#        label  "All Activities"
#        url    { me_activities_path }
#        active { controller?('me/activities') and params[:view].empty? }
#      end
#      local_section :my do
#        label  "Mine"
#        url    { me_activities_path(:view => 'my') }
#        active { controller?('me/activities') and params[:view] == 'my' }
#      end
#      local_section :friends do
#        label  "People"
#        url    { me_activities_path(:view => 'friends') }
#        active { controller?('me/activities') and params[:view] == 'friends' }
#      end
#      local_section :groups do
#        label  "Groups"
#        url    { me_activities_path(:view => 'groups') }
#        active { controller?('me/activities') and params[:view] == 'groups' }
#      end
#    end

#    context_section :calendar do
#      label  "Calendar"
#      url    { me_events_path }
#      active { controller?('me/events') }
#      icon   :date
#    end

    context_section :messages do
      label  { :messages.t }
      url    { me_discussions_path }
      active { controller?('me/discussions', 'me/posts') }
      icon   :page_message
    end

    context_section :settings do
      label  { :settings.t }
      url    { me_settings_path }
      active { controller?('me/settings', 'me/permissions', 'me/profile', 'me/requests', 'me/passwords', 'me/destroys') }
      icon   :control

      local_section :settings do
        label  { :account_settings.t }
        url    { me_settings_path }
        active { controller?('me/settings') }
      end

      local_section :permissions do
        label  { :permissions.t }
        url    { me_permissions_path }
        active { controller?('me/permissions') }
      end

      local_section :profile do
        label  { :profile.t }
        url    { edit_me_profile_path }
        active { controller?('me/profile') }
      end

      local_section :requests do
        label  { :requests.t }
        url    { me_requests_path }
        active { controller?('me/requests') }
      end

      local_section :password do
        label  { :password.t }
        url    { edit_me_password_path }
        active { controller?('me/passwords') }
      end

      local_section :destroy do
        label  { :destroy.t }
        url    { me_destroy_path }
        active { controller?('me/destroys') }
      end

    end

  end

  ##
  ## PEOPLE
  ##

  global_section :people do
    label  { :people.t }
    url    :controller => 'people/directory'
    active { controller?('people/') or context?(:user) }
    html    :partial => '/layouts/global/nav/people_menu'

    context_section :no_context do
      visible { context?(:none) }
      active  { context?(:none) }

      local_section :all do
        label { :all.t }
        url { people_directory_path }
        active { params[:path].empty? }
      end

      local_section :friends do
        visible { logged_in? }
        label { :friends.t }
        url { people_directory_path(:path => ['contacts']) }
        active { params[:path].try(:include?, 'contacts') }
      end

      local_section :peers do
        visible { logged_in? }
        label { :peers.t }
        url { people_directory_path(:path => ['peers']) }
        active { params[:path].try(:include?, 'peers') }
      end

    end

    context_section :home do
      label  { :home.t }
      icon   :house
      url    { entity_path(@user) }
      active { controller?('people/home') }
    end

    context_section :pages do
      label  { :pages.t }
      icon   :page_white_copy
      url    { person_pages_path(@user) }
      active { page_controller? }
    end

  end

  ##
  ## GROUPS
  ##

  global_section :group do
    label  { :groups.t }
    url    { groups_directory_path }
    active { controller?('groups/') or context?(:group) }
    html    :partial => '/layouts/global/nav/groups_menu'

    context_section :directory do
      #visible { context?(:none) and controller?('groups/directory') }
      #active  { context?(:none) and controller?('groups/directory') }

      visible { context?(:none) }
      active  { context?(:none) }

      local_section :all do
        label { :all.t }
        url { groups_directory_path }
        active { controller?('groups/directory') and params[:path].empty? }
      end

      local_section :mygroups do
        visible { logged_in? }
        label { :my_groups.t }
        url { groups_directory_path(:path => ['my']) }
        active { controller?('groups/directory') and params[:path].try(:include?, 'my') }
      end

      local_section :create do
        label   { :create_thing.t(:thing => :group.t) }
        url     { new_group_path }
        active  { controller?('groups/groups') }
        icon    :plus
      end

    end

    context_section :home do
      label  { :home.t }
      icon   :house
      url    { entity_path(@group) }
      active { controller?('groups/home', 'groups/wikis', 'wikis/versions', 'wikis/diffs') }
    end

    context_section :pages do
      label  { :pages.t }
      icon   :page_white_copy
      url    { group_pages_path(@group) }
      active { page_controller? }
    end

#    context_section :calendar do
#      label  { :calendar.t }
#      url    { group_events_path(@group) }
#      active { controller?('groups/events') }
#      icon   :date
#    end

    context_section :members do
      visible { may_list_memberships? }
      label   { :members.t }
      icon    :user
      url     { group_memberships_path(@group) }
      active  { controller?('groups/memberships', 'groups/invites', 'groups/membership_requests') }

      local_section :people do
        visible { may_list_memberships? }
        label   { :people.t }
        url     { group_memberships_path(@group) }
        active  { controller?('groups/memberships') and params[:view] != 'groups' }
      end

      local_section :groups do
        visible { may_list_memberships? and @group.network? }
        label   { :groups.t }
        url     { group_memberships_path(@group, :view => 'groups') }
        active  { controller?('groups/memberships') and params[:view] == 'groups' }
      end

      local_section :invites do
        visible { may_admin_group? }
        label   { :send_invites.t }
        url     { new_group_invite_path(@group) }
        active  { controller?('groups/invites') }
      end

      local_section :requests do
        visible { may_admin_group? }
        label   { :membership_requests.t }
        url     { group_membership_requests_path(@group) }
        active  { controller?('groups/membership_requests') }
      end

      #local_section :leave_group_link do
      #  visible { may_leave_group? }
      #  html    { leave_group_link }
      #end

      #local_section :membership_settings do
      #  visible { may_edit_group? }
      #  label   { 'Membership Settings' }
      #  url     { group_permissions_path(@group, :view => 'membership') }
      #  active  false
      #end

    end

    context_section :settings do
      visible { may_admin_group? }
      label  { :settings.t }
      icon   :control
      url    { group_settings_path(@group) }
      active { controller?('groups/settings', 'groups/permissions', 'groups/profiles', 'groups/structures', 'groups/requests') }

      local_section :settings do
        visible { may_admin_group? }
        label  { :basic_settings.t }
        url    { group_settings_path(@group) }
        active { controller?('groups/settings') }
      end

      local_section :permissions do
        visible { may_admin_group? }
        label  { :permissions.t }
        url    { group_permissions_path(@group) }
        active { controller?('groups/permissions') }
      end

      local_section :profile do
        visible { may_admin_group? }
        label  { :profile.t }
        url    { edit_group_profile_path(@group) }
        active { controller?('groups/profiles') }
      end

      local_section :structure do
        visible { may_admin_group? }
        label  { :structure.t }
        url    { group_structure_path(@group) }
        active { controller?('groups/structures') }
      end

      local_section :requests do
        visible { may_admin_group? }
        label  { :requests.t }
        url    { group_requests_path(@group) }
        active { controller?('groups/requests') }
      end
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


class Group::DirectoryController < ApplicationController
  before_action :login_required
  # skip_before_action :login_required
  # ^^ for now, disable public directories. The old behavior was to require
  #    authentication to browse the directory, so we don't want to change this
  #    unexpectedly without either giving groups some warning or adding an
  #    additional level to the permissions.

  before_action :set_default_path

  helper 'group/directory'

  def index
    @groups = groups_to_display.order(:name).paginate(pagination_params)
  end

  protected

  def set_default_path
    params[:path] = default_path if params[:path].empty?
  end

  def default_path
    if logged_in? && current_user.groups.any?
      'my'
    else
      'all'
    end
  end

  helper_method :my_groups?

  def my_groups?
    logged_in? && params[:path].start_with?('my')
  end

  def groups_to_display
    if search_filter
      groups_in_view.named_like("#{search_filter}%")
    else
      if my_groups?
        groups_in_view
      else
        Group.none # we might want to display promoted groups here at some point
      end
    end
  end

  def groups_in_view
    if my_groups?
      current_user.primary_groups_and_networks
    else
      Group.with_access(current_user => :view)
    end
  end

  def search_filter
    return @filter if defined?(@filter)
    @filter = get_filter_from_params
  end

  def get_filter_from_params
    if params[:q].present?
      params[:q]
    elsif params[:path].include? 'search/'
      params[:path].sub(/.*search\//, '')
    end
  end
end

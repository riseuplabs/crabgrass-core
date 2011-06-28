class Groups::DirectoryController < ApplicationController

  def index
    @groups = Group.paginate(pagination_params)
  end

end


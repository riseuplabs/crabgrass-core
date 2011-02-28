class Groups::DirectoryController < ApplicationController

  def index
    @groups = Group.all
  end



end


class People::DirectoryController < ApplicationController

  def index
    @users = User.all
  end

end


```
class RobotsController < ApplicationController

  before_action :login_required       # if you want to require logins
  after_action :verify_authorized     # ensures authorization happened

  def create
    @robot = Robot.new robot_params   # initialize a new object
    authorize @robot                  # use pundit for authorization
    @robot.save                       # persist the object
  end

  protected

  # make use of strong parameters
  def robot_params
    params.require(:robot).permit(:size, :age)
  end
end
```

General Guidelines
============================

(1) Controllers should be use resource routes whenever possible and it makes sense to.
    If you have a controller that provides logic to some database object or objects,
    it can almost always be decomposed into multiple REST-like controllers.

(2) thin controllers are good, even if this means some code duplication:
    for example, controllers for me/pages and groups/pages is OK.
    most the logic is handled elsewhere.
    this makes it much easier to have clean routes and permissions.

(3) Plain ruby objects can help encapsulate relevant records
    for dealing with multi step create processes
    and checking permissions through pundit.
    See app/models/message.rb for an example.


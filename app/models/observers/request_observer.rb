#
# manage notices about requests
#

class RequestObserver < ActiveRecord::Observer

  def after_create(request)
    RequestNotice.create! request
  end

  def after_update(request)
    # if the request is not pending, get rid of all related notices
    unless request.pending?
      RequestNotice.dismiss_all(request)
    end
  end

end

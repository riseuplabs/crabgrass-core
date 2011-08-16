module RequestHelper

  def context_request_path(*args)
    if @group
      group_request_path(@group, *args)
    else
      me_requests_path(*args)
    end
  end
end

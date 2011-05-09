#
# Some media processing jobs take a long time and are better handled by
# another server. A RemoteJob lets us create these remote processing jobs.
#


class RemoteJob < ActiveResource::Base

  if Conf.remote_processing
    self.site = Conf.remote_processing
    self.format = :xml
    self.element_name = "job"
  end

end



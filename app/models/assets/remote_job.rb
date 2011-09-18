#
# Some media processing jobs take a long time and are better handled by
# another server. A RemoteJob lets us create these remote processing jobs.
#
# see initializers/remote_job.rb
#

class RemoteJob < ActiveResource::Base
  ALLOWED_FIELDS = [
    :input_type, :input_url, :input_file, :input_data,
    :output_type, :output_url, :output_file, :output_data,
    :options, :failed_callback_url, :success_callback_url]

  def self.create!(attrs)
    attrs.each do |key, value|
      unless ALLOWED_FIELDS.include? key
        attrs.delete(key)
      end
    end
    begin
      self.create(attrs)
    end
  end

  self.format = :xml
  self.element_name = "job"

  # returns true if the remote processing server is run on the same
  # machine as this process.
  def self.local?
    self.site =~ /localhost/
  end

end




class ThumbnailController < ApplicationController

  def show
    @thumbnail = Thumbnail.find(params[:id])
    if params[:status] == 'success'
      @job       = @thumbnail.remote_job
      @thumbnail.set_data_from_url open(@job.data_url).read
      @job.update_attribute(:status => 'finished')

      render :text => 'success', :status => 200
    elsif params[:status] == 'failure'
      @thumbnail.update_attribute(:failure, true)
    end

#    if binary request
#      thumbnail.set_data read_binary_data
#    else
#      thumbnail.set_data params[:output_data]
#thumbnail.remote_job.output_data
#    end
#    thumbnail.save
  end


end

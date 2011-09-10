#
# for now, this controller is just used by remote processing to 
# report back to us that the file is finished processing.
#
# TODO: ensure that only the remote processor can hit these actions
#

class ThumbnailController < ApplicationController

  def show
    @thumbnail = Thumbnail.find(params[:id])
    if params[:status] == 'success'
      @thumbnail.fetch_data_from_remote_job
    elsif params[:status] == 'failure'
      @thumbnail.update_attribute(:failure, true)
    end

    # acknowledge that we received the callback
    render :text => 'success', :status => 200

#    if binary request
#      thumbnail.set_data read_binary_data
#    else
#      thumbnail.set_data params[:output_data]
#thumbnail.remote_job.output_data
#    end
#    thumbnail.save
  end


end

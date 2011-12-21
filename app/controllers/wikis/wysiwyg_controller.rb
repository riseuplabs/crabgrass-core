# this is currently not used. We only use it to store old pieces of
# wysiwyg functionality.

class Wikis::WysiwygController < Wikis::BaseController


  protected
  # Handle the switch between Greencloth wiki a editor and Wysiwyg wiki editor
  def update_editors
    return unless @wiki.document_open_for?(current_user)
    render :json => update_editor_data(:editor => params[:editor], :wiki => params[:wiki])
  end
end

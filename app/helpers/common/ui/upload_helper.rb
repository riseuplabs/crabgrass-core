module Common::Ui::UploadHelper

  #
  # asset_upload_form_for
  #
  # adds a form that uploads a file to an iframe as a create request to
  # the targets AssetController.
  # This controller can then use render_to_parent to update the page
  # context accordingly.
  #
  def asset_upload_form_for(target, message = nil)
    target = target.becomes(Page) if target.is_a?(Page)
    render :partial => '/common/asset_upload',
      :locals => {:target => target, :message => message}
  end
end

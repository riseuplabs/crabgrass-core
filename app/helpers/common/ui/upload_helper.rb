module Common::Ui::UploadHelper

  #
  # asset_upload_form_for
  #
  # adds a form that uploads a file to an iframe as a create request to
  # the targets AssetController.
  # This controller can then use render_to_parent to update the page
  # context accordingly.
  #
  def asset_upload_form_for(target, options = {})
    target = target.becomes(Page) if target.is_a?(Page)
    render partial: '/common/asset_upload',
      locals: options.merge({target: target})
  end

  def upload_form_options(options = {})
   html = { enctype: "multipart/form-data", id: 'upload-form' }
   html[:class] = 'single' if options[:single]
   return { html: html }
  end

end

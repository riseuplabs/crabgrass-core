module DismodPageHelper

  def delete_button
    if current_user.may?(:edit, @page) and @version.version < @asset.version
      button_to('Destroy',
        page_xpath(@page,
          :action => 'destroy',
          :version => @version.version
        ),
        {:confirm => 'Are you sure you want to delete version %s?' % @version.version}
      )
    else
      ""
    end
  end

  def edit_button
    form_options = {
      :action => page_xpath(@page,:action => 'Model_Design_Agent'),
      :method => 'get',
      :class => 'button-to'
    }
    content_tag(:form, form_options) {[
        content_tag(:input, '', :type => 'hidden', :name => 'version', :value => @version.version),
        content_tag(:input, '', :type => 'submit', :value => 'Edit')
    ]}
  end

  def processing_link
    link_to_modal('processing...', 
      {:html => '<p>here will be live info about the state of the dismod processing</p>'},
      {:class => 'icon spinner_icon'}
    )
  end

  # 
  # TODO: auth auth key to the url
  #
  def dismod_get_dataset_url
    if params[:version].any?
      path = page_xpath(@page, :action => 'dataset', :user => current_user.login, :version => params[:version]) + '&x=x' 
    else
      path = page_xpath(@page, :action => 'dataset', :user => current_user.login)
    end
    request.protocol + request.host_with_port + path
  end

end


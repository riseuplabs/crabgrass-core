class Pages::TrashController < Pages::SidebarsController

  guard :may_admin_page?
  helper 'pages/trash'

  # loads popup
  def edit
  end

  def update
    case params[:type]
      when 'move_to_trash' then move
      when 'shred_now'     then shred
      when 'undelete'      then undelete
      when 'destroy'       then destroy
      else raise_error 'unknown type'
    end
  end

  protected

  def undelete
    @page.undelete
    render(:update) {|page| page.redirect_to page_url(@page)}
  end

#  def delete
#    url = from_url(@page)
#    @page.delete
#    redirect_to url
#  end

  def destroy
    @page.destroy
    render(:update) {|page| page.redirect_to new_url}
  end

  def move
    @page.delete
    render(:update) {|page| page.redirect_to new_url}
  end

  def shred
    @page.destroy
    render(:update) {|page| page.redirect_to new_url}
  end

  def new_url
    if @page.owner and @page.owner != current_user
      entity_url @page.owner
    else
      me_url
    end
  end
  helper_method :new_url

end


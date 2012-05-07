class PageObserver < ActiveRecord::Observer

  def after_destroy(page)
    PageNotice.destroy_all_by_page(page)
  end

end

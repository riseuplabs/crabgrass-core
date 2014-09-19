# These currently only work with javascript.
module PageActions

  def tag_page(tags)
    tags = tags.join(', ') if tags.respond_to? :join
    within '#tag_li' do
      click_on 'Edit'
    end
    fill_in 'add', :with => tags
    click_on 'Add'
  end

end

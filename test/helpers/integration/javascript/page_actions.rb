# These currently only work with javascript.
module PageActions

  def share_page_with(*entities)
    click_on 'Share Page'
    add_recipients *entities
    click_on 'Share'
    # wait until sharing completed...
    find '.names', text: entities.last.display_name
  end

  def tag_page(tags)
    tags = tags.join(', ') if tags.respond_to? :join
    within '#tag_li' do
      click_on 'Edit'
    end
    fill_in 'add', with: tags
    click_on 'Add'
  end

end

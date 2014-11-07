# These currently only work with javascript.
module PageActions

  def share_page_with(*entities)
    click_on 'Share Page'
    add_recipients *entities, autocomplete: true
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

  def delete_page(page = @page)
    click_on 'Delete Page'
    click_button 'Delete'
    # ensure after_commit callbacks are triggered so sphinx indexes the page.
    page.page_terms.committed!
  end

  def undelete_page(page = @page)
    click_on 'Undelete'
    # ensure after_commit callbacks are triggered so sphinx indexes the page.
    page.page_terms.committed!
  end

  #
  # Add recipients in the page creation or share forms
  #
  # options:
  #
  # autocomplete: use the autocomplete popup. This will fail if
  #               the user in question is not visible.
  #
  def add_recipients(*args)
    options = args.extract_options!
    args.each do |recipient|
      add_recipient(recipient, options)
    end
  end

  def add_recipient(recipient, options = {})
    if options[:autocomplete]
      autocomplete :recipient_name, with: recipient.name
    else
      # the space is a work around as the first letter may get cut off
      fill_in :recipient_name, with: ' ' + recipient.name
      find('#add_recipient_button').click
    end
    # this may be in an error message or the list of shares.
    assert_content recipient.name
    # make sure all the autocomplete requests have been responded to
    # before we move on...
    wait_for_ajax
  end

  def autocomplete(field, options)
    # the space is a work around as the first letter may get cut off
    fill_in field, with: ' ' + options[:with][0,2]
    # poltergeist will not keep the element focussed.
    # But when we loose focus the autocomplete won't show.
    execute_script("$('recipient_name').focus();")
    find('.autocomplete em', text: options[:with]).click
  end

end

module PageAssertions

  def assert_page_tags(tags)
    # split a string but not an array
    tags = tags.split(',') unless tags.respond_to? :each
    within '.tags' do
      tags.each do |tag|
        assert_content tag
      end
    end
  end

  def assert_page_users(*users)
    user_names = users.map(&:display_name).join(' ')
    names_text = find('#people.names').text
    assert_equal user_names.split(' ').sort, names_text.split(' ').sort
  end

  def assert_page_groups(*groups)
    assert_equal groups.map(&:display_name).join(' '),
      find('#groups.names').text
  end


  def assert_page_starred
    assert_selector '#star.star_16'
  end

  def assert_page_not_starred
    assert_selector '#star.star_empty_dark_16'
  end

  def assert_page_watched
    assert_selector '#watch_checkbox.check_on_16'
  end

  def assert_page_not_watched
    assert_selector '#watch_checkbox.check_off_16'
  end
end

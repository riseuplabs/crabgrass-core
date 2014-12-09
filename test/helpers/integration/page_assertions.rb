module PageAssertions

  def assert_page_tags(tags)
    tags.split(',') if tags.respond_to? :split
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
end

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
    assert_equal users.map(&:display_name).join(' '),
      find('#people.names').text
  end

  def assert_page_groups(*groups)
    assert_equal groups.map(&:display_name).join(' '),
      find('#groups.names').text
  end
end

module PageAssertions

  def assert_page_tags(tags)
    tags.split(',') if tags.respond_to? :split
    within '.tags' do
      tags.each do |tag|
        assert_content tag
      end
    end
  end
end

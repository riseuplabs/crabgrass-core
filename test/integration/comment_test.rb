require 'integration_test'

class CommentTest < IntegrationTest
  def setup
    super
    @blue = users(:blue)
    @red = users(:red)
    @rainbow = groups(:rainbow)
    @page = FactoryBot.create :page, created_by: @blue, owner: @rainbow
    @blue_comment = @page.add_post @blue,
                                   body: 'test comment that already existed'
    @red_comment = @page.add_post @red,
                                  body: 'test comment by red that already existed'
  end

  def test_star_comments
    login @red
    visit "/pages/#{@page.name_url}"
    assert may_star?(@red_comment, false)
    assert_equal 0, star_count(@blue_comment)
    assert_equal 0, star_count(@red_comment)
    star_comment @blue_comment
    assert_equal 1, star_count(@blue_comment)
    assert_equal 0, star_count(@red_comment)
    unstar_comment @blue_comment
    assert_equal 0, star_count(@blue_comment)
  end

  protected

  def may_star?(comment, value)
    within_comment(comment) do
      if value
        assert_selector('a.shy', visible: false, text: 'Add Star')
      else assert_no_content('Star')
           assert_no_selector('a.shy', visible: false, text: 'Add Star')
      end
    end
  end

  def star_comment(comment)
    within_comment(comment) do
      find('.shy_parent a.shy.star_plus_16', visible: false).click
    end
  end

  def unstar_comment(comment)
    within_comment(comment) do
      find('.shy_parent a.shy.star_minus_16', visible: false).click
    end
  end

  def star_count(comment)
    within_comment(comment) do
      find('[data-stars]')['data-stars'].to_i
    end
  end

  def within_comment(comment, &block)
    within "#post_#{comment.id}", &block
  end
end

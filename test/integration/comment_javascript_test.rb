# encoding: utf-8
require 'javascript_integration_test'

class CommentJavascriptTest < JavascriptIntegrationTest

  fixtures :users, :groups

  def setup
    super
    @blue = users(:blue)
    @red = users(:red)
    @rainbow = groups(:rainbow)
    @page = FactoryBot.create :page, created_by: @blue, owner: @rainbow
    @blue_comment = @page.add_post @blue,
                                   body: 'test comment by blue that already existed'
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

  def test_edit_comment
    login @blue
    visit "/pages/#{@page.name_url}"
    edit_comment(@blue_comment, 'edited by blue')
    assert_content 'edited by blue'
  end

  def test_delete_comment
    login @blue
    visit "/pages/#{@page.name_url}"
    delete_comment(@blue_comment)
    assert_no_content 'test comment by blue that already existed'
    assert_content 'test comment by red that already existed'
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

  def edit_comment(comment, text)
    within_comment(comment) do
      find('a.icon.pencil_16', visible: false).click
      fill_in :post_body, with: text
      click_on 'Save'
    end
  end

  def delete_comment(comment)
    within_comment(comment) do
      find('a.icon.pencil_16', visible: false).click
      click_on 'Delete'
      sleep 1
    end
  end

  def star_comment(comment)
    within_comment(comment) do
      find('a.star_plus_16', visible: false).click
      sleep 1
    end
  end

  def unstar_comment(comment)
    within_comment(comment) do
      find('a.star_minus_16', visible: false).click
      sleep 1
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

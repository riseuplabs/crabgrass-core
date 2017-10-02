require 'test_helper'

class Page::TagSuggestionsTest < ActiveSupport::TestCase
  
  fixtures :users
 
  def test_recent_and_popular_tags
    tag_list = ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen']
    create_user_page tag_list: tag_list
    page = create_user_page
    suggestor = tag_suggestor(page, users(:blue))  
    recent = recent_tags(suggestor) 
    assert_equal ['eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen'].sort, recent
    popular = popular_tags suggestor
    assert_equal  ["one", "two", "three", "four", "five", "six"], popular
  end

  def test_popular_tags
    popular = ['apple', 'cherry', 'grape', 'orange', 'banana', 'strawberry']
    not_popular = ['bug', 'error', 'fault']
    3.times {create_user_page tag_list: popular}
    create_user_page tag_list: not_popular
    page = create_user_page
    tag_suggestor = tag_suggestor(page, users(:blue))
    popular.each do |tag|
      assert popular.include? tag 
    end
  end


  protected

  def tag_suggestor page, user
    Page::TagSuggestions.new(page, user)
  end

  def recent_tags tag_suggestor
    tag_suggestor.recent_tags.map(&:name).sort
  end

  def popular_tags tag_suggestor
    tag_suggestor.popular_tags.map(&:name)
  end

  def create_group_page(options = {})     
    attrs = options.reverse_merge created_by: users(:blue),
    owner: groups(:rainbow)     
    FactoryGirl.create :page, attrs   
  end   

  def create_user_page(options = {})
    attrs = options.reverse_merge created_by: users(:blue)
    FactoryGirl.create :page, attrs
  end

 

end

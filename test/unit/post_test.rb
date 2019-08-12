require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts

  def test_with_link
    [:greencloth_link, :auto_link, :html_link].each do |fixture_name|
      assert posts(fixture_name).with_link?,
        "Post fixture '#{fixture_name}' has a link but with_link? says it doesn't."
    end

    fixture_name = :no_link
    refute posts(fixture_name).with_link?,
      "Post fixture '#{fixture_name}' has no link but with_link? says it does."

  end

end

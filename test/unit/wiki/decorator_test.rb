require 'test_helper'

class Wiki::DecoratorTest < ActiveSupport::TestCase

  def test_keep_plain_text_nodes
    wiki = Wiki.new body: <<-EOWIKI
h2. heading

 content outside the default paras
Some content
    EOWIKI
    decorator = Wiki::Decorator.new wiki, dummy_view
    decorator.decorate :document
    # everything should be wrapped in one big div.
    assert_equal 1, decorator.doc.children.count
  end

  def dummy_view
    stub edit_wiki_section_link: "<a>edit</a>",
      div_for: '<div></div>'
  end

end

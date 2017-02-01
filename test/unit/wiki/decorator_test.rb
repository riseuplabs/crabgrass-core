require 'test_helper'

class Wiki::DecoratorTest < ActiveSupport::TestCase

  def test_simple_wiki
    wiki = Wiki.new body: simple_wiki
    assert_decorated_content_of wiki, <<-EOML
<div><h2 class=\"first shy_parent\"><a name=\"heading\"></a>heading<a class=\"anchor\" href=\"#heading\">&para;</a><a>edit</a></h2>
<p>Some content</p></div>
    EOML
  end

  # everything should be wrapped in one big div.
  def test_keep_plain_text_nodes
    wiki = Wiki.new body: wiki_with_outside_content
    assert_decorated_content_of wiki, <<-EOML
<div><h2 class=\"first shy_parent\"><a name=\"heading\"></a>heading<a class=\"anchor\" href=\"#heading\">&para;</a><a>edit</a></h2>
content outside the default paras
<p>Some content</p></div>
    EOML
  end

  def test_headings_that_caused_errors
    wiki = Wiki.new body: wiki_with_troublesome_headings
    decorator = Wiki::Decorator.new wiki, dummy_view
    decorator.decorate :document
    assert_includes decorator.to_html, 'a name='
  end


  def assert_decorated_content_of(wiki, expected)
    decorator = Wiki::Decorator.new wiki, dummy_view
    decorator.decorate :document
    assert_equal Nokogiri::HTML.fragment(expected.chomp).to_html, decorator.to_html
  end

  def dummy_view
    stub edit_wiki_section_link: "<a>edit</a>",
      div_for: '<div></div>'
  end

  def wiki_with_outside_content
    simple_wiki " content outside the default paras\n"
  end

  def simple_wiki(additional_content = nil)
    <<-EOWIKI
h2. heading

#{additional_content}Some content
    EOWIKI
  end

  def wiki_with_troublesome_headings
    <<-EOWIKI
    h2. 1. heading

    content

    h2. +++ heading +++

    content
    EOWIKI
  end
end

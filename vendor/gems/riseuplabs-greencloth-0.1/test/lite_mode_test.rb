require 'rubygems'
require 'minitest/autorun'
require 'yaml'
require 'byebug'

test_dir =  File.dirname(File.expand_path(__FILE__))
require test_dir + '/../lib/greencloth.rb'

class TestLiteMode < MiniTest::Test

  def setup
  end

  def test_filter_html
    html = GreenCloth.new("aaa <script>alert('hi')</script> aa", 'page', [:lite_mode]).to_html
    assert_equal "aaa &lt;script&gt;alert('hi')&lt;/script&gt; aa", html
  end
end

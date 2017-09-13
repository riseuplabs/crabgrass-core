require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  def test_defaults_to_conf
    assert_equal Conf.title, Site.new.title
  end

  def test_overwrite_default
    with_site 'domain', title: 'other title' do
      assert_equal 'other title', Site.for_domain('domain').title
      assert_equal Conf.title, Site.default.title
    end
  end

  def with_site(domain, attributes = {}, &block)
    Conf.stub :sites, { domain => attributes.stringify_keys }, &block
  end
end

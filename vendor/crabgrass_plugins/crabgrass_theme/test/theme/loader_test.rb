require_relative '../test_helper'
require 'tmpdir'
require 'pathname'
require 'fileutils'
require 'crabgrass/theme/loader'
require 'byebug'

class Crabgrass::Theme::LoaderTest < MiniTest::Test

  class TestDummy
    include Crabgrass::Theme::Loader
  end

  def test_resolve_path
    Dir.mktmpdir do |dir|
      dir = Pathname.new(dir)
      parent = dir + 'nest/some/more'
      link = parent + 'link'
      target = dir + 'nest/other/branch'
      parent.mkpath
      target.mkpath
      symlink = File.symlink('../../other/branch', link)
      assert_equal target.to_s, TestDummy.new.send(:resolve_dir, link.to_s)
      assert File.exist?(TestDummy.new.send(:resolve_dir, link))
    end
  end
end

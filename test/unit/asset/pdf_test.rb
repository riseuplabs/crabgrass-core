require 'test_helper'

class Asset::PdfTest < ActiveSupport::TestCase
  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_pdf_upload
    skip if ENV['GITLAB_CI']
    @asset = Asset.create_from_params uploaded_data: upload_data('test.pdf')
    @asset.generate_thumbnails
    @asset.thumbnails.each do |thumb|
      assert thumb.ok?, format('generating thumbnail "%s" should have succeeded', thumb.name)
      assert thumb.private_filename, format('thumbnail "%s" should exist', thumb.name)
    end
  end
end

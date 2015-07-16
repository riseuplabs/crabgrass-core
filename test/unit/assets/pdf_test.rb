require 'test_helper'

module Assets
  class PdfTest < ActiveSupport::TestCase

    def setup
      setup_assets
    end

    def teardown
      teardown_assets
    end

    def test_pdf_upload
      @asset = Asset.create_from_params uploaded_data: upload_data('test.pdf')
      @asset.generate_thumbnails
      @asset.thumbnails.each do |thumb|
        assert thumb.ok?, 'generating thumbnail "%s" should have succeeded' % thumb.name
        assert thumb.private_filename, 'thumbnail "%s" should exist' % thumb.name
      end
    end

  end
end

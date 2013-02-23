require File.dirname(__FILE__) + '/test_helper'

class AssetTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess

  def setup
    Media::Transmogrifier.verbose = true  # set to true to see all the commands being run.
    FileUtils.mkdir_p(ASSET_PRIVATE_STORAGE)
    FileUtils.mkdir_p(ASSET_PUBLIC_STORAGE)
    RemoteJob.site = 'http://localhost:3002'
  end

  def teardown
    FileUtils.rm_rf(ASSET_PRIVATE_STORAGE)
    FileUtils.rm_rf(ASSET_PUBLIC_STORAGE)
    Conf.remote_processing = Conf.remote_processing
  end

  def test_doc
    if remote_available?
      asset = TextAsset.create! :uploaded_data => upload_data('msword.doc')
      thumbnail = asset.thumbnails.select{|thumb|thumb.name == 'pdf'}.first
      thumbnail.generate
    end
  end

  def test_binary

  end

  def test_failure
  end

  protected

  def remote_available?
    begin
      RemoteJob.find(:all)
    rescue Errno::ECONNREFUSED => exc
      info 'skipping remote_job_test: cg-processor is not running'
      return false
    end
    return true
  end

end

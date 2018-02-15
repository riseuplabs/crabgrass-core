module PgpTestHelper
  def create_fresh_gpg_directory
    gpg_dir = Rails.root.join('assets','keyrings', "tmp").to_s
    FileUtils.rm_rf(gpg_dir) if File.exist?(gpg_dir)
    FileUtils.makedirs(gpg_dir)
    ENV['GNUPGHOME']=gpg_dir
  end
end

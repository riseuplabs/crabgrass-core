#
# Pgp Key
#
# after key upload, the user receives an encrypted notification
# if the key has an expiration date, we store it in the database
#
#

class PgpKey < ApplicationRecord

  belongs_to :user
  before_validation :update_key
  after_save :notify_user, if: :saved_change_to_key?

  def expired?
    return false if self.expires == nil # valid forever
    self.expires < 15.minutes.from_now
  end

  protected

  def update_key
    if self.will_save_change_to_key?
      PgpKey.create_fresh_gpg_directory
      import_key
    end
  end

  def import_key
    unless self.key.present?
      return self.fingerprint = nil
    end
    if import_fingerprint = GPGME::Key.import(self.key).imports.first.try.fpr
      if valid_key = GPGME::Key.find(:fingerprint, import_fingerprint).first
        self.fingerprint = import_fingerprint
        self.expires = valid_key.expires
      else
        errors.add :pgp_key, I18n.t(:pgp_key_expired)
        self.key = nil
        self.fingerprint = nil
      end
    else
       errors.add :pgp_key, I18n.t(:pgp_key_invalid)
       self.key = nil
       self.fingerprint = nil
    end
  end

  def notify_user
    begin
      Mailer::PgpKeyUploadMailer.key_uploaded_mail(self.user).deliver_now
    rescue Mail::Gpg::MissingKeysError => e
    end
  end

  def self.create_fresh_gpg_directory
    gpg_dir = Rails.root.join('assets','keyrings', "tmp").to_s
    FileUtils.rm_rf(gpg_dir) if File.exist?(gpg_dir)
    FileUtils.makedirs(gpg_dir)
    ENV['GNUPGHOME']=gpg_dir
  end

end

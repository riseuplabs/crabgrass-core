#     create_table "wiki_versions", :force => true do |t|
#       t.integer  "wiki_id",    :limit => 11
#       t.integer  "version",    :limit => 11
#       t.text     "body"
#       t.text     "body_html"
#       t.text     "raw_structure"
#       t.datetime "updated_at"
#       t.integer  "user_id",    :limit => 11
#     end
#
#     add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
#     add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

module WikiExtension
  module Versioning

    class VersionNotFoundException < ArgumentError
    end

    def create_new_version? #:nodoc:
      body_updated = body_changed?
      recently_edited_by_same_user = !user_id_changed? && (updated_at and (updated_at > 30.minutes.ago))

      latest_version_has_blank_body = self.versions.last && self.versions.last.body.blank?

      # always create a new version if we have no versions at all
      # don't create a new version if
      #   * a new version would be on top of an old blank version (we don't want to store blank versions)
      #   * the same user is making several edits in sequence
      #   * the body hasn't changed
      return (versions.empty? or (body_updated and !recently_edited_by_same_user and !latest_version_has_blank_body))
    end

    # returns first version since +time+
    def first_version_since(time)
      return nil unless time
      versions.first :conditions => ["updated_at <= :time", {:time => time}],
        :order => "updated_at DESC"
    end

    def find_version(number)
      self.versions.find_by_version(number) or
      raise VersionNotFoundException.new(
        :version_doesnt_exist.t(:version => number))
    end

    # reverts and keeps all the old versions
    def revert_to(version, user)
      self.body = version.body
      self.user = user
      save!
    end

    # reverts and deletes all versions after the reverted version.
    def revert_to_version!(version_number, user=nil)
      revert_to(version_number)
      destroy_versions_after(version_number)
    end

    # update the latest Wiki::Version object with the newest attributes
    # when wiki changes, but a new version is not being created
    def update_latest_version_record
      # only need to update the latest version when not creating a new one
      return if create_new_version?
      versions.last.update_attributes(
        :body => body,
        # read_attributes for body_html and raw_structure
        # because we don't want to trigger another rendering
        # by calling our own body_html method
        :body_html => read_attribute(:body_html),
        :raw_structure => read_attribute(:raw_structure),
        :user => user,
        :updated_at => Time.now)
    end

    protected

    def destroy_versions_after(version_number)
      versions.find(:all, :conditions => ["version > ?", version_number]).each do |version|
        version.destroy
      end
    end

  end
end


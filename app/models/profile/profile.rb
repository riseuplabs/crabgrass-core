#
# A person or group profile
#
# Every person or group can have many profiles, each with different permissions
# and for different languages. A given user will only see one of these profiles,
# the one that matches their language and relationship to the user/group.
#
# Order of profile presidence (user sees the first one that matches):
#  (1) foe
#  (2) friend   } the 'private' profile
#  (3) peer     } might see 'private' profile or the 'public' profile
#  (4) stranger } the 'public' profile
#   create_table "profiles", :force => true do |t|
#     t.integer  "entity_id",              :limit => 11
#     t.string   "entity_type"
#     t.boolean  "stranger",                             :default => false, :null => false
#     t.boolean  "peer",                                 :default => false, :null => false
#     t.boolean  "friend",                               :default => false, :null => false
#     t.boolean  "foe",                                  :default => false, :null => false
#     t.string   "first_name"
#     t.string   "middle_name"
#     t.string   "last_name"
#     t.string   "role"
#     t.string   "organization"
#     t.datetime "created_at"
#     t.datetime "updated_at"
#     t.text     "summary"
#     t.integer  "wiki_id",                :limit => 11
#     t.integer  "photo_id",               :limit => 11
#     t.integer  "layout_id",              :limit => 11
#     t.integer  "membership_policy",      :limit => 11, :default => 0
#     t.string   "language",               :limit => 5
#     t.integer  "discussion_id",          :limit => 11
#     t.string   "place"
#     t.integer  "video_id",               :limit => 11
#     t.text     "summary_html",
#     t.integer  "geo_location_id"
#   end
#
# Currently unused: language.
#

class Profile < ApplicationRecord
  belongs_to :language

  ##
  ## RELATIONSHIPS TO USERS AND GROUPS
  ##

  belongs_to :entity, polymorphic: true
  def user
    entity
  end

  def group
    entity
  end

  before_create :fix_polymorphic_single_table_inheritance
  def fix_polymorphic_single_table_inheritance
    self.entity_type = 'User' if entity_type =~ /User/
    self.entity_type = 'Group' if entity_type =~ /Group/
  end

  ##
  ## CONSTANTS
  ##

  # approval - user requests to join, group members approce (the default)
  # open - anyone can join the group
  MEMBERSHIP_POLICY = { approval: 0, open: 1 }.freeze

  ##
  ## BASIC ATTRIBUTES
  ##

  format_attribute :summary

  def full_name
    [first_name, middle_name, last_name].reject(&:blank?) * ' '
  end
  alias name full_name

  def public?
    stranger?
  end

  def private?
    friend?
  end

  def hidden?
    # a profile is hidden if no relationship fields are set
    !(friend? || stranger? || foe? || peer?)
  end

  def type
    return 'public' if stranger?
    return 'private' if friend?
    'unknown'
  end

  def membership_policy_is?(name)
    membership_policy == MEMBERSHIP_POLICY[name.to_sym]
  end

  ##
  ## ASSOCIATED ATTRIBUTES
  ##

  belongs_to :wiki, dependent: :destroy
  belongs_to :picture, dependent: :destroy
  belongs_to :video, class_name: 'ExternalVideo', dependent: :destroy

  has_many :websites,
           class_name: '::ProfileWebsite',
           dependent: :destroy

  # takes a huge params hash that includes sub hashes for dependent collections
  # and saves it all to the database.
  def save_from_params(profile_params)
    valid_params = %w[first_name middle_name last_name role
                      organization place membership_policy
                      peer picture video summary admins_may_moderate]

    collections = {
      'websites'  => ::ProfileWebsite
    }
    profile_params.to_h.stringify_keys!

    params = profile_params.delete_if { |k, _v| !valid_params.include?(k) && !collections.keys.include?(k) }
    params['summary_html'] = nil if params['summary'] == ''

    # save nil if value is an empty string:
    params.each do |key, value|
      params[key] = value.presence
    end

    # build objects from params
    collections.each do |collection_name, collection_class|
      params[collection_name] = begin
                                  profile_params[collection_name].collect do |_key, value|
                                    # puts "%s.new ( %s )" % [collection_class, value.inspect]
                                    collection_class.create(value.merge('profile_id' => id.to_i))
                                  end || []
                                rescue
                                  []
                                end
    end

    picture_params = params.delete('picture')
    if picture_params && picture_params['upload']
      params['picture'] = Picture.new(picture_params)
    end
    params['video'] = ExternalVideo.new(params.delete('video')) if params['video']

    update_attributes(params)
    reload # huh? why is this needed?
    self
  rescue ErrorMessage
    # In case the picture update did not work... let's keep the old one.
    self.picture_id = picture_id_was
    # still raise the error message
    raise
  end

  def cover
    picture || video
  end

  def summary_html
    super.try :html_safe
  end

end # class

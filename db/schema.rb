# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180426154112) do

  create_table "activities", force: :cascade do |t|
    t.integer  "subject_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.string   "subject_name", limit: 255
    t.integer  "item_id",      limit: 4
    t.string   "item_type",    limit: 255
    t.string   "item_name",    limit: 255
    t.string   "type",         limit: 255
    t.string   "extra",        limit: 255
    t.integer  "key",          limit: 4
    t.datetime "created_at"
    t.integer  "access",       limit: 2,   default: 2
    t.integer  "related_id",   limit: 4
    t.integer  "site_id",      limit: 4
    t.boolean  "flag"
  end

  add_index "activities", ["created_at"], :name => "created_at"
  execute "CREATE INDEX subject_0_4_0 ON activities (subject_id,subject_type(4),access)"

  create_table "asset_versions", force: :cascade do |t|
    t.integer  "asset_id",       limit: 4
    t.integer  "version",        limit: 4
    t.integer  "parent_id",      limit: 4
    t.string   "content_type",   limit: 255
    t.string   "filename",       limit: 255
    t.string   "thumbnail",      limit: 255
    t.integer  "size",           limit: 4
    t.integer  "width",          limit: 4
    t.integer  "height",         limit: 4
    t.integer  "page_id",        limit: 4
    t.datetime "created_at"
    t.string   "versioned_type", limit: 255
    t.datetime "updated_at"
    t.integer  "user_id",        limit: 4
    t.text     "comment",        limit: 65535
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["parent_id"], :name => "index_asset_versions_parent_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", force: :cascade do |t|
    t.string   "content_type",  limit: 255
    t.string   "filename",      limit: 255
    t.integer  "size",          limit: 4
    t.integer  "width",         limit: 4
    t.integer  "height",        limit: 4
    t.string   "type",          limit: 255
    t.integer  "page_id",       limit: 4
    t.datetime "created_at"
    t.integer  "version",       limit: 4
    t.integer  "page_terms_id", limit: 4
    t.boolean  "is_attachment",               default: false
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.datetime "updated_at"
    t.string   "caption",       limit: 255
    t.datetime "taken_at"
    t.string   "credit",        limit: 255
    t.integer  "user_id",       limit: 4
    t.text     "comment",       limit: 65535
  end

  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"
  add_index "assets", ["page_terms_id"], :name => "pterms"

  create_table "avatars", force: :cascade do |t|
    t.binary  "image_file_data", limit: 4294967295
    t.boolean "public",                             default: false
  end

  create_table "castle_gates_keys", force: :cascade do |t|
    t.integer "castle_id",     limit: 4
    t.string  "castle_type",   limit: 255
    t.integer "holder_code",   limit: 4
    t.integer "gate_bitfield", limit: 4,   default: 1
  end

  add_index "castle_gates_keys", ["castle_id", "castle_type", "holder_code"], :name => "index_castle_gates_by_castle_and_holder_code"

  create_table "csp_reports", force: :cascade do |t|
    t.text     "document_uri",        limit: 65535
    t.text     "referrer",            limit: 65535
    t.text     "violated_directive",  limit: 65535
    t.text     "effective_directive", limit: 65535
    t.text     "original_policy",     limit: 65535
    t.text     "blocked_uri",         limit: 65535
    t.integer  "status_code",         limit: 4
    t.text     "ip",                  limit: 65535
    t.text     "user_agent",          limit: 65535
    t.boolean  "report_only"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_appearances", force: :cascade do |t|
    t.text     "parameters",        limit: 65535
    t.integer  "parent_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "masthead_asset_id", limit: 4
    t.integer  "favicon_id",        limit: 4
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,        default: 0
    t.integer  "attempts",   limit: 4,        default: 0
    t.text     "handler",    limit: 16777215
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discussions", force: :cascade do |t|
    t.integer  "posts_count",      limit: 4,   default: 0
    t.datetime "replied_at"
    t.integer  "replied_by_id",    limit: 4
    t.integer  "last_post_id",     limit: 4
    t.integer  "page_id",          limit: 4
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
  end

  add_index "discussions", ["page_id"], :name => "index_discussions_page_id"

  create_table "event_recurrencies", force: :cascade do |t|
    t.integer  "event_id",          limit: 4
    t.datetime "start"
    t.datetime "end"
    t.string   "type",              limit: 255
    t.string   "day_of_the_week",   limit: 255
    t.string   "day_of_the_month",  limit: 255
    t.string   "month_of_the_year", limit: 255
    t.datetime "created_at",                    null: false
  end

  create_table "events", force: :cascade do |t|
    t.text     "description",      limit: 16777215
    t.text     "description_html", limit: 16777215
    t.boolean  "is_all_day",                        default: false
    t.boolean  "is_cancelled",                      default: false
    t.boolean  "is_tentative",                      default: true
    t.string   "location",         limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "owner_code",       limit: 4
  end

  add_index "events", ["starts_at"], :name => "index_events_on_starts_at"
  add_index "events", ["ends_at"], :name => "index_events_on_ends_at"

  create_table "external_videos", force: :cascade do |t|
    t.string   "media_key",           limit: 255
    t.string   "media_url",           limit: 255
    t.string   "media_thumbnail_url", limit: 255
    t.text     "media_embed",         limit: 65535
    t.integer  "page_terms_id",       limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "height",              limit: 2
    t.integer  "width",               limit: 2
    t.integer  "player",              limit: 2
  end

  create_table "federatings", force: :cascade do |t|
    t.integer  "group_id",      limit: 4
    t.integer  "network_id",    limit: 4
    t.integer  "council_id",    limit: 4
    t.integer  "delegation_id", limit: 4
    t.datetime "created_at"
  end

  add_index "federatings", ["group_id", "network_id"], :name => "gn"
  add_index "federatings", ["network_id", "group_id"], :name => "ng"

  create_table "group_participations", force: :cascade do |t|
    t.integer  "group_id",          limit: 4
    t.integer  "page_id",           limit: 4
    t.integer  "access",            limit: 4
    t.boolean  "static",                      default: false
    t.datetime "static_expires"
    t.boolean  "static_expired",              default: false
    t.integer  "featured_position", limit: 4
  end

  add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"

  create_table "groups", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "full_name",           limit: 255
    t.string   "url",                 limit: 255
    t.string   "type",                limit: 255
    t.integer  "parent_id",           limit: 4
    t.integer  "council_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id",           limit: 4
    t.string   "style",               limit: 255
    t.string   "language",            limit: 5
    t.integer  "version",             limit: 4,   default: 0
    t.integer  "min_stars",           limit: 4,   default: 1
    t.integer  "site_id",             limit: 4
    t.boolean  "full_council_powers",             default: false
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["parent_id"], :name => "index_groups_parent_id"

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id",     limit: 4
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.boolean  "admin",                    default: false
    t.datetime "visited_at",               default: '1000-01-01 00:00:00', null: false
    t.integer  "total_visits", limit: 4,   default: 0
    t.string   "join_method",  limit: 255
  end

  add_index "memberships", ["group_id", "user_id"], :name => "gu"
  add_index "memberships", ["user_id", "group_id"], :name => "ug"

  create_table "migrations_info", force: :cascade do |t|
    t.datetime "created_at"
  end

  create_table "notices", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.integer  "user_id",        limit: 4
    t.integer  "avatar_id",      limit: 4
    t.text     "data",           limit: 16777215
    t.integer  "noticable_id",   limit: 4
    t.string   "noticable_type", limit: 255
    t.boolean  "dismissed",                       default: false
    t.datetime "dismissed_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "notices", ["user_id"], :name => "index_notices_on_user_id"

  create_table "page_access_codes", force: :cascade do |t|
    t.string   "code",       limit: 10
    t.integer  "page_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "access",     limit: 4
    t.datetime "expires_at"
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_access_codes", ["code"], :name => "index_page_access_codes_on_code", :unique => true
  add_index "page_access_codes", ["expires_at"], :name => "index_page_access_codes_on_expires_at"

  create_table "page_histories", force: :cascade do |t|
    t.integer  "user_id",                     limit: 4
    t.integer  "page_id",                     limit: 4
    t.string   "type",                        limit: 255
    t.datetime "created_at"
    t.integer  "item_id",                     limit: 4
    t.string   "item_type",                   limit: 255
    t.datetime "notification_sent_at"
    t.datetime "notification_digest_sent_at"
    t.string   "details",                     limit: 255
  end

  add_index "page_histories", ["user_id"], :name => "index_page_histories_on_user_id"
  add_index "page_histories", ["page_id"], :name => "index_page_histories_on_page_id"

  create_table "page_terms", force: :cascade do |t|
    t.integer  "page_id",            limit: 8
    t.string   "page_type",          limit: 255
    t.text     "access_ids",         limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "comments",           limit: 16777215
    t.string   "tags",               limit: 255
    t.string   "title",              limit: 255
    t.boolean  "resolved"
    t.integer  "rating",             limit: 4
    t.integer  "contributors_count", limit: 4
    t.integer  "flow",               limit: 4,        default: 0
    t.string   "created_by_login",   limit: 255
    t.string   "updated_by_login",   limit: 255
    t.integer  "created_by_id",      limit: 8
    t.integer  "updated_by_id",      limit: 8
    t.datetime "page_updated_at"
    t.datetime "page_created_at"
    t.boolean  "delta"
    t.string   "media",              limit: 255
    t.integer  "stars_count",        limit: 4,        default: 0
    t.string   "owner_name",         limit: 255
    t.integer  "owner_id",           limit: 4
  end

  add_index "page_terms", ["page_id"], :name => "page_id"
  add_index "page_terms", ["delta"], :name => "index_page_terms_on_delta"
  execute "ALTER TABLE page_terms ENGINE = MyISAM"
  execute "CREATE FULLTEXT INDEX idx_fulltext ON page_terms (access_ids,tags)"

  create_table "page_tools", force: :cascade do |t|
    t.integer "page_id",   limit: 4
    t.integer "tool_id",   limit: 4
    t.string  "tool_type", limit: 255
  end

  add_index "page_tools", ["page_id", "tool_id"], :name => "index_page_tools"

  create_table "pages", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved",                            default: true
    t.boolean  "public"
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.text     "summary",            limit: 16777215
    t.string   "type",               limit: 255
    t.integer  "message_count",      limit: 4,        default: 0
    t.integer  "data_id",            limit: 4
    t.string   "data_type",          limit: 255
    t.integer  "contributors_count", limit: 4,        default: 0
    t.string   "name",               limit: 255
    t.string   "updated_by_login",   limit: 255
    t.string   "created_by_login",   limit: 255
    t.integer  "flow",               limit: 4,        default: 0
    t.integer  "stars_count",        limit: 4,        default: 0
    t.integer  "owner_id",           limit: 4
    t.string   "owner_type",         limit: 255
    t.string   "owner_name",         limit: 255
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.integer  "site_id",            limit: 4
    t.datetime "happens_at"
    t.integer  "cover_id",           limit: 4
  end

  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  execute "CREATE INDEX owner_name_4 ON pages (owner_name(4))"
  add_index "pages", ["name", "owner_id"], :name => "index_pages_on_name"
  add_index "pages", ["data_id", "data_type"], :name => "index_pages_on_data_id_and_data_type"

  create_table "pgp_keys", force: :cascade do |t|
    t.text     "key",         limit: 65535
    t.string   "fingerprint", limit: 255
    t.integer  "user_id",     limit: 4
    t.datetime "expires"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.string  "content_type",  limit: 255
    t.string  "caption",       limit: 255
    t.string  "credit",        limit: 255
    t.string  "dimensions",    limit: 255
    t.boolean "public"
    t.string  "average_color", limit: 255
  end

  create_table "plugin_schema_info", id: false, force: :cascade do |t|
    t.string  "plugin_name", limit: 255
    t.integer "version",     limit: 4
  end

  create_table "polls", force: :cascade do |t|
    t.string "type", limit: 255
  end

  create_table "possibles", force: :cascade do |t|
    t.string  "name",             limit: 255
    t.text    "action",           limit: 16777215
    t.integer "poll_id",          limit: 4
    t.text    "description",      limit: 16777215
    t.text    "description_html", limit: 16777215
    t.integer "position",         limit: 4
  end

  add_index "possibles", ["poll_id"], :name => "index_possibles_poll_id"

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "discussion_id", limit: 4
    t.text     "body",          limit: 16777215
    t.text     "body_html",     limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "type",          limit: 255
    t.integer  "page_terms_id", limit: 4
    t.integer  "stars_count",   limit: 4,        default: 0
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"

  create_table "profiles", force: :cascade do |t|
    t.integer  "entity_id",              limit: 4
    t.string   "entity_type",            limit: 255
    t.boolean  "stranger",                             default: false, null: false
    t.boolean  "peer",                                 default: false, null: false
    t.boolean  "friend",                               default: false, null: false
    t.boolean  "foe",                                  default: false, null: false
    t.string   "name_prefix",            limit: 255
    t.string   "first_name",             limit: 255
    t.string   "middle_name",            limit: 255
    t.string   "last_name",              limit: 255
    t.string   "name_suffix",            limit: 255
    t.string   "nickname",               limit: 255
    t.string   "role",                   limit: 255
    t.string   "organization",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "birthday"
    t.boolean  "fof",                                  default: false, null: false
    t.text     "summary",                limit: 65535
    t.integer  "wiki_id",                limit: 4
    t.integer  "layout_id",              limit: 4
    t.boolean  "may_see"
    t.boolean  "may_see_committees"
    t.boolean  "may_see_networks"
    t.boolean  "may_see_members"
    t.boolean  "may_request_membership"
    t.integer  "membership_policy",      limit: 4,     default: 0
    t.boolean  "may_see_groups"
    t.boolean  "may_see_contacts"
    t.boolean  "may_request_contact",                  default: true
    t.boolean  "may_pester",                           default: true
    t.boolean  "may_burden"
    t.boolean  "may_spy"
    t.string   "language",               limit: 5
    t.integer  "discussion_id",          limit: 4
    t.string   "place",                  limit: 255
    t.integer  "video_id",               limit: 4
    t.text     "summary_html",           limit: 65535
    t.integer  "geo_location_id",        limit: 4
    t.integer  "picture_id",             limit: 4
    t.boolean  "encrypt",                              default: false
  end

  add_index "profiles", ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], :name => "profiles_index"
  add_index "profiles", ["wiki_id", "entity_id"], :name => "profiles_for_wikis"

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating",        limit: 4,  default: 0
    t.datetime "created_at",                            null: false
    t.string   "rateable_type", limit: 15, default: "", null: false
    t.integer  "rateable_id",   limit: 4,  default: 0,  null: false
    t.integer  "user_id",       limit: 4,  default: 0,  null: false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  add_index "ratings", ["rateable_type", "rateable_id"], :name => "fk_ratings_rateable"

  create_table "relationships", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "contact_id",    limit: 4
    t.string   "type",          limit: 10
    t.integer  "discussion_id", limit: 4
    t.datetime "visited_at",               default: '1000-01-01 00:00:00', null: false
    t.integer  "unread_count",  limit: 4,  default: 0
    t.integer  "total_visits",  limit: 4,  default: 0
  end

  add_index "relationships", ["contact_id", "user_id"], :name => "index_contacts"
  add_index "relationships", ["discussion_id"], :name => "index_relationships_on_discussion_id"

  create_table "requests", force: :cascade do |t|
    t.integer  "created_by_id",         limit: 4
    t.integer  "approved_by_id",        limit: 4
    t.integer  "recipient_id",          limit: 4
    t.string   "recipient_type",        limit: 5
    t.string   "email",                 limit: 255
    t.string   "code",                  limit: 8
    t.integer  "requestable_id",        limit: 4
    t.string   "requestable_type",      limit: 10
    t.integer  "shared_discussion_id",  limit: 4
    t.integer  "private_discussion_id", limit: 4
    t.string   "state",                 limit: 10
    t.string   "type",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",              limit: 255
    t.integer  "site_id",               limit: 4
  end

  execute "CREATE INDEX created_by_0_2 ON requests (created_by_id,state(2))"
  execute "CREATE INDEX recipient_0_2_2 ON requests (recipient_id,recipient_type(2),state(2))"
  execute "CREATE INDEX requestable_0_2_2 ON requests (requestable_id,requestable_type(2),state(2))"
  add_index "requests", ["code"], :name => "code"
  add_index "requests", ["created_at"], :name => "created_at"
  add_index "requests", ["updated_at"], :name => "updated_at"

  create_table "showings", force: :cascade do |t|
    t.integer "asset_id",         limit: 4
    t.integer "gallery_id",       limit: 4
    t.integer "position",         limit: 4,   default: 0
    t.boolean "is_cover",                     default: false
    t.integer "stars",            limit: 4
    t.integer "comment_id_cache", limit: 4
    t.integer "discussion_id",    limit: 4
    t.string  "title",            limit: 255
  end

  add_index "showings", ["gallery_id", "asset_id"], :name => "ga"
  add_index "showings", ["asset_id", "gallery_id"], :name => "ag"

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,   null: false
    t.integer  "starred_id",   limit: 4,   null: false
    t.string   "starred_type", limit: 255, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "question_id",       limit: 4
    t.integer  "response_id",       limit: 4
    t.integer  "asset_id",          limit: 4
    t.text     "value",             limit: 65535
    t.string   "type",              limit: 255
    t.datetime "created_at"
    t.integer  "external_video_id", limit: 4
  end

  create_table "survey_questions", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.text     "choices",    limit: 65535
    t.integer  "survey_id",  limit: 4
    t.integer  "position",   limit: 4
    t.string   "label",      limit: 255
    t.text     "details",    limit: 65535
    t.boolean  "required"
    t.datetime "created_at"
    t.datetime "expires_at"
    t.string   "regex",      limit: 255
    t.integer  "maximum",    limit: 4
    t.integer  "minimum",    limit: 4
    t.boolean  "private",                  default: false
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer  "survey_id",   limit: 4
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.integer  "stars_count", limit: 4,   default: 0
    t.datetime "created_at"
  end

  create_table "surveys", force: :cascade do |t|
    t.text     "description",     limit: 65535
    t.datetime "created_at"
    t.integer  "responses_count", limit: 4,     default: 0
    t.string   "settings",        limit: 255
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "taggable_id",   limit: 4
    t.integer  "tag_id",        limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.string   "context",       limit: 128
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["taggable_type"], :name => "index_taggings_on_taggable_type"
  add_index "taggings", ["tagger_id"], :name => "index_taggings_on_tagger_id"
  add_index "taggings", ["context"], :name => "index_taggings_on_context"
  add_index "taggings", ["tagger_id", "tagger_type"], :name => "index_taggings_on_tagger_id_and_tagger_type"
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], :name => "taggings_idy"

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["name"], :name => "tags_name"

  create_table "task_participations", force: :cascade do |t|
    t.boolean "watching"
    t.boolean "waiting"
    t.boolean "assigned"
    t.integer "user_id",  limit: 4
    t.integer "task_id",  limit: 4
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 16777215
    t.text     "description_html", limit: 16777215
    t.integer  "position",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "due_at"
    t.integer  "created_by_id",    limit: 4
    t.integer  "updated_by_id",    limit: 4
    t.integer  "points",           limit: 4
    t.integer  "page_id",          limit: 4
  end

  add_index "tasks", ["page_id", "position"], :name => "index_tasks_on_page_id_and_position"

  create_table "thumbnails", force: :cascade do |t|
    t.integer "parent_id",    limit: 8
    t.string  "parent_type",  limit: 255
    t.string  "content_type", limit: 255
    t.string  "filename",     limit: 255
    t.string  "name",         limit: 255
    t.integer "size",         limit: 8
    t.integer "width",        limit: 8
    t.integer "height",       limit: 8
    t.boolean "failure"
  end

  add_index "thumbnails", ["parent_id", "parent_type"], :name => "parent_id_and_type"

  create_table "tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,   default: 0,  null: false
    t.string   "action",     limit: 255, default: "", null: false
    t.string   "value",      limit: 40,  default: "", null: false
    t.datetime "created_at",                          null: false
  end

  create_table "translations", force: :cascade do |t|
    t.text     "text",        limit: 65535
    t.integer  "key_id",      limit: 4
    t.integer  "language_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "custom",                    default: false
  end

  add_index "translations", ["key_id"], :name => "index_translations_on_key_id"

  create_table "user_participations", force: :cascade do |t|
    t.integer  "page_id",       limit: 4
    t.integer  "user_id",       limit: 4
    t.integer  "folder_id",     limit: 4
    t.integer  "access",        limit: 4
    t.datetime "viewed_at"
    t.datetime "changed_at"
    t.boolean  "watch",                   default: false
    t.boolean  "star"
    t.boolean  "resolved",                default: true
    t.boolean  "viewed"
    t.integer  "message_count", limit: 4, default: 0
    t.boolean  "attend",                  default: false
  end

  add_index "user_participations", ["page_id", "user_id"], :name => "page_and_user", :unique => true
  add_index "user_participations", ["user_id", "changed_at"], :name => "recent_changes"

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "display_name",              limit: 255
    t.string   "time_zone",                 limit: 255
    t.integer  "avatar_id",                 limit: 4
    t.datetime "last_seen_at"
    t.integer  "version",                   limit: 4,     default: 0
    t.binary   "direct_group_id_cache",     limit: 65535
    t.binary   "all_group_id_cache",        limit: 65535
    t.binary   "friend_id_cache",           limit: 65535
    t.binary   "foe_id_cache",              limit: 65535
    t.binary   "peer_id_cache",             limit: 65535
    t.binary   "tag_id_cache",              limit: 65535
    t.string   "language",                  limit: 5
    t.binary   "admin_for_group_id_cache",  limit: 65535
    t.boolean  "unverified",                              default: false
    t.string   "receive_notifications",     limit: 255
    t.string   "type",                      limit: 255
    t.string   "password_digest",           limit: 255
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "votes", force: :cascade do |t|
    t.integer  "possible_id",  limit: 4
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.integer  "value",        limit: 4
    t.string   "comment",      limit: 255
    t.string   "type",         limit: 255
    t.integer  "votable_id",   limit: 4
    t.string   "votable_type", limit: 255
  end

  add_index "votes", ["possible_id"], :name => "index_votes_possible"
  add_index "votes", ["possible_id", "user_id"], :name => "index_votes_possible_and_user"

  create_table "websites", force: :cascade do |t|
    t.integer "profile_id", limit: 4
    t.boolean "preferred",              default: false
    t.string  "site_title", limit: 255, default: ""
    t.string  "site_url",   limit: 255, default: ""
  end

  add_index "websites", ["profile_id"], :name => "websites_profile_id_index"

  create_table "wiki_locks", force: :cascade do |t|
    t.integer "wiki_id",      limit: 4
    t.text    "locks",        limit: 65535
    t.integer "lock_version", limit: 4,     default: 0
  end

  add_index "wiki_locks", ["wiki_id"], :name => "wiki_id"

  create_table "wiki_versions", force: :cascade do |t|
    t.integer  "wiki_id",       limit: 4
    t.integer  "version",       limit: 4
    t.text     "body",          limit: 16777215
    t.text     "body_html",     limit: 16777215
    t.datetime "updated_at"
    t.integer  "user_id",       limit: 4
    t.text     "raw_structure", limit: 65535
  end

  add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
  add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

  create_table "wikis", force: :cascade do |t|
    t.text     "body",          limit: 16777215
    t.text     "body_html",     limit: 16777215
    t.datetime "updated_at"
    t.integer  "user_id",       limit: 4
    t.integer  "version",       limit: 4
    t.text     "raw_structure", limit: 65535
  end

  add_index "wikis", ["user_id"], :name => "index_wikis_user_id"

end

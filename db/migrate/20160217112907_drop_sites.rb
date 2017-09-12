class DropSites < ActiveRecord::Migration
  def up
    drop_table :sites
  end

  def down
    create_table 'sites', force: true do |t|
      t.string  'name'
      t.string  'domain'
      t.string  'email_sender'
      t.integer 'pagination_size'
      t.integer 'super_admin_group_id'
      t.text    'translators', limit: 2_147_483_647
      t.string  'translation_group'
      t.string  'default_language'
      t.text    'available_page_types',   limit: 2_147_483_647
      t.text    'evil',                   limit: 2_147_483_647
      t.boolean 'tracking'
      t.boolean 'default', default: false
      t.integer 'network_id'
      t.integer 'custom_appearance_id'
      t.boolean 'has_networks', default: true
      t.string  'signup_redirect_url'
      t.string  'title'
      t.boolean 'enforce_ssl'
      t.boolean 'show_exceptions'
      t.boolean 'require_user_email'
      t.integer 'council_id'
      t.string  'login_redirect_url'
      t.boolean 'chat'
      t.boolean 'limited'
      t.integer 'signup_mode',            limit: 1
      t.string  'email_sender_name',      limit: 40
      t.string  'profiles'
      t.string  'profile_fields'
      t.boolean 'require_user_full_info'
    end

    add_index 'sites', ['name'], name: 'index_sites_on_name', unique: true
  end
end

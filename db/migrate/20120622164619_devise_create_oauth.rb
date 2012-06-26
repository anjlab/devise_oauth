class DeviseCreateOauth < ActiveRecord::Migration
  def change
    create_table :oauth_clients do |t|
      # client_ownable devise strategy
      t.integer  :owner_id

      t.string   :identifier, null: false
      t.string   :name, null: false
      t.string   :secret, null: false
      t.string   :site_uri, null: false
      t.text     :redirect_uris
      t.text     :info
      t.integer  :scope_mask, null: false, default: 0

      t.integer  :granted_times, null: false, default: 0
      t.integer  :revoked_times, null: false, default: 0

      t.datetime :blocked_at
      t.timestamps
    end

    add_index :oauth_clients, :identifier, unique: true
    add_index :oauth_clients, :secret, unique: true
    add_index :oauth_clients, :owner_id

    create_table :oauth_authorizations do |t|
      t.integer  :client_id, null: false
      t.integer  :resource_owner_id, null: false
      t.integer  :scope_mask, null: false, default: 0
      t.string   :redirect_uri
      t.string   :code, null: false
      t.datetime :expires_at, null: false

      t.datetime :used_at

      t.datetime :blocked_at
      t.timestamps
    end

    add_index :oauth_authorizations, :client_id
    add_index :oauth_authorizations, :resource_owner_id
    add_index :oauth_authorizations, :code, unique: true

    # for authorization and access tokens
    create_table :oauth_access_tokens do |t|
      t.integer  :client_id, null: false
      t.integer  :resource_owner_id, null: false
      t.integer  :scope_mask, null: false, default: 0
      t.string   :value, null: false
      t.datetime :expires_at, null: false

      t.string   :refresh_token

      t.datetime :blocked_at
      t.timestamps
    end

    add_index :oauth_access_tokens, :client_id
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :value, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true

    create_table :oauth_accesses do |t|
      t.integer  :client_id, null: false
      t.integer  :resource_owner_id, null: false

      t.integer  :accessed_times, null: false, default: 0

      t.datetime :blocked_at
      t.timestamps
    end

    add_index :oauth_accesses, :client_id
    add_index :oauth_accesses, :resource_owner_id
  end
end
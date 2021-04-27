class CreateVersions < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :versions do |t|
      t.string   :versionable_type, null: false
      t.integer  :versionable_id,   null: false
      t.string   :event,            null: false
      t.string   :committer
      t.text     :object
      t.boolean  :draft,            default: false
      t.text     :commit_message
      t.datetime :committed_at

      t.timestamps null: false
    end

    add_index :versions, [:versionable_type, :versionable_id]
  end
end

module ActiveVersioning
  module Test
    class Database < ActiveRecord::Migration[5.2]
      def self.build
        ActiveRecord::Base.establish_connection(
          adapter:  'sqlite3',
          database: ':memory:'
        )

        new.migrate(:up)
      end

      def initialize
        self.verbose = false
      end

      def change
        create_table :users do |t|
          t.string :name
          t.string :email
        end

        create_table :posts do |t|
          t.string     :title
          t.text       :body
          t.references :user, index: true, foreign_key: true

          t.timestamps null: false
        end

        create_table :comments do |t|
          t.string     :author
          t.text       :body
          t.references :post, index: true, foreign_key: true

          t.timestamps null: false
        end

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
  end
end

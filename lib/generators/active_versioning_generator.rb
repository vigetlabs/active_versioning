require 'rails/generators/active_record/migration'

class ActiveVersioningGenerator < Rails::Generators::Base
  include ActiveRecord::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  def install_models
    copy_file 'models/version.rb', 'app/models/version.rb'
  end

  def install_migrations
    migration_template 'migrations/create_versions.rb', 'db/migrate/create_versions.rb'
  end
end

require 'rails'
require 'active_versioning/version'
require 'generators/active_versioning/install_generator'

module ActiveVersioning
  autoload :Errors,         'active_versioning/errors'
  autoload :Events,         'active_versioning/events'
  autoload :Model,          'active_versioning/model'
  autoload :VersionManager, 'active_versioning/version_manager'

  def self.versioned_models
    @@versioned_models ||= begin
      Rails.application.eager_load!

      ActiveRecord::Base.descendants.select do |model|
        model.included_modules.include? Model::Versioned
      end
    end
  end
end

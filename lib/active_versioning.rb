require 'active_versioning/version'
require 'generators/active_versioning_generator'

module ActiveVersioning
  autoload :Events,         'active_versioning/events'
  autoload :Model,          'active_versioning/model'
  autoload :VersionManager, 'active_versioning/version_manager'
end

require 'active_versioning/version'
require 'generators/active_versioning/install_generator'

module ActiveVersioning
  autoload :Errors,         'active_versioning/errors'
  autoload :Events,         'active_versioning/events'
  autoload :Model,          'active_versioning/model'
  autoload :VersionManager, 'active_versioning/version_manager'
end

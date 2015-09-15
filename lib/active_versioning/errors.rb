module ActiveVersioning
  module Errors
    autoload :IncompatibleVersion, 'active_versioning/errors/incompatible_version'

    RecordNotPersisted = Class.new(StandardError)
    InvalidVersion     = Class.new(StandardError)
  end
end

module ActiveVersioning
  module Errors
    class IncompatibleVersion < StandardError
      attr_reader :record, :version

      def initialize(record, version)
        @record  = record
        @version = version
      end
    end
  end
end

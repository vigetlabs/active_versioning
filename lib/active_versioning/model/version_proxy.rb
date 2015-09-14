module ActiveVersioning
  module Model
    class VersionProxy < Delegator
      #
      # VersionProxy class
      #
      # Uses Ruby's Delegator class to delegate methods to the versioned
      # resource.  The bulk of this class overrides the Rails save, update, and
      # reload methods to modify the record in the versions table as opposed
      # to the versioned resource.
      #
      # A `commit` instance method writes to the versioned resource's record.

      VersionInvalid = Class.new(StandardError)

      attr_reader :version

      def initialize(version)
        @version = version
        __setobj__(version.reify)
      end

      def __getobj__
        @record
      end

      def __setobj__(record)
        @record = record
      end

      # `class` should delegate to versioned resource, not return
      # ActiveVersioning::Model::VersionProxy
      undef class

      def reload
        __setobj__(version.reify)
      end

      def to_param
        version.versionable.to_param
      end

      def save(*)
        if valid?
          version.update(version_attributes)
        else
          false
        end
      end

      def save!(*)
        if valid?
          version.update!(version_attributes)
        else
          raise ::ActiveRecord::RecordInvalid.new(__getobj__)
        end
      end

      def update(attributes)
        raise draft_exception unless version.draft?

        with_transaction_returning_status do
          assign_attributes(attributes)
          save
        end
      end
      alias update_attributes update

      def update!(attributes)
        raise draft_exception unless version.draft?

        with_transaction_returning_status do
          assign_attributes(attributes)
          save!
        end
      end
      alias update_attributes! update!

      def live?
        false
      end

      def version?
        true
      end

      def commit(params = {})
        raise draft_exception unless version.draft?

        attrs = version_attributes.tap do |attrs|
          attrs.merge!(
            draft:        false,
            event:        ActiveVersioning::Events::COMMIT,
            committed_at: Time.current
          )

          attrs.merge!(params)
        end

        version.update(attrs)

        __getobj__.update(versioned_attributes)
      end

      private

      def draft_exception
        VersionInvalid.new("Version #{version.id} must be a draft")
      end

      def version_attributes
        {
          committer: version_author,
          object:    versioned_attributes
        }
      end
    end
  end
end

module ActiveVersioning
  module Model
    module Versioned
      RecordNotPersisted = Class.new(StandardError)

      mattr_accessor :blacklisted_attributes do
        %w(created_at updated_at published)
      end

      def self.included(base)
        base.class_eval do
          has_many :versions, -> { newest_first }, as: :versionable, dependent: :destroy

          after_create :create_version!

          # Set by controller params
          attr_accessor :version_author
        end
      end

      def live?
        true
      end

      def version?
        false
      end

      def current_draft(force_reload = false)
        unless persisted?
          raise RecordNotPersisted.new("#{self} must be persisted to create a draft version")
        end

        @current_draft = nil if force_reload

        @current_draft ||= begin
          # FIXME: Gracefully handle NoMethodError and UnknownAttributeError
          # If past versions contain renamed/different attributes, this causes problems
          # Detect such attributes and warn appropriately.
          # Create a nice errors object that encapsulates this information that can be used to diff.

          VersionProxy.new(versions.draft.first_or_create(
            object: versioned_attributes,
            event:  'draft'
          ))
        end
      end

      def current_draft?
        versions.draft.present?
      end

      def destroy_draft
        versions.draft.destroy_all
      end

      # Usage: resource.create_draft_from_version(params[:version_id])
      def create_draft_from_version(version_id)
        original_version = versions.find(version_id)
        current_draft(true).assign_attributes(original_version.object)
        current_draft.save
      end

      def versioned_attributes
        versioned_attribute_names.reduce(Hash.new) do |attrs, name|
          attrs.merge(name => send(name))
        end
      end

      # Overridable in the class to add things like `photo_id`
      def versioned_attribute_names
        attribute_names - blacklisted_attributes
      end

      private

      def create_version!
        versions.create!(
          event:        'create',
          committer:    version_author,
          committed_at: Time.current,
          object:       versioned_attributes
        )
      end
    end
  end
end

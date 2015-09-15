module ActiveVersioning
  module Model
    module Versioned
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
          raise ActiveVersioning::Errors::RecordNotPersisted.new("#{self} must be persisted to create a draft version")
        end

        @current_draft = nil if force_reload

        @current_draft ||= VersionProxy.new(versions.draft.first_or_create(
          object: versioned_attributes,
          event:  'draft'
        ))
      end

      def current_draft?
        versions.draft.present?
      end

      def destroy_draft
        versions.draft.destroy_all
      end

      def version_manager
        @version_manager ||= VersionManager.new(self)
      end

      def create_draft_from_version(version_id)
        version_manager.create_draft_from_version(version_id) and current_draft(true)
      end

      def versioned_attributes
        versioned_attribute_names.reduce(Hash.new) do |attrs, name|
          attrs.merge(name => send(name))
        end
      end

      def versioned_attribute_names
        attribute_names - VersionManager::BLACKLISTED_ATTRIBUTES
      end

      private

      def create_version!
        versions.create!(
          event:        ActiveVersioning::Events::CREATE,
          committer:    version_author,
          committed_at: Time.current,
          object:       versioned_attributes
        )
      end
    end
  end
end

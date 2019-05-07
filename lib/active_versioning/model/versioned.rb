module ActiveVersioning
  module Model
    module Versioned
      def self.included(base)
        base.class_eval do
          has_many :versions, -> { newest_first }, as: :versionable, dependent: :destroy

          after_create :create_version!

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

      def self_attributes
        versioned_attribute_names.reduce(Hash.new) do |attrs, name|
          attrs.merge(name => public_send(name))
        end
      end

      def nested_attributes
        versioned_nested_attribute_names.reduce(Hash.new) do |attrs, name|
          if nested_attributes_names.include?(name)
            nested_association = association(name)
            reflection = nested_association.reflection

            nested_attrs = if reflection.belongs_to? || reflection.has_one?
              public_send(name).try(:public_send, :attributes)
            else
              public_send(name).map { |a| a.attributes }
            end

            if nested_attrs.present?
              attrs.merge("#{name}_attributes" => nested_attrs)
            else
              attrs
            end
          end
        end || {}
      end

      def versioned_attributes
        self_attributes.merge(nested_attributes)
      end

      def nested_attributes_names
        nested_attributes_options.keys.map(&:to_s)
      end

      def versioned_attribute_names
        attribute_names - VersionManager::BLACKLISTED_ATTRIBUTES
      end

      def versioned_nested_attribute_names
        []
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

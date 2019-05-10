module ActiveVersioning
  module Model
    extend ActiveSupport::Concern

    autoload :Versioned,    'active_versioning/model/versioned'
    autoload :VersionProxy, 'active_versioning/model/version_proxy'

    included do
      belongs_to :versionable, polymorphic: true

      serialize :object, Hash

      validates :event, presence: true, inclusion: { in: ActiveVersioning::Events::ALL }

      scope :newest_first, -> { order created_at: :desc }
      scope :draft,        -> { where draft: true }
      scope :committed,    -> { where draft: false }

      def to_s
        [
          versionable.to_s,
          committed_at.try(:utc).try(:strftime, '#%Y%m%d%H%M%S')
        ].compact.join(' ')
      end

      def reify
        resource = reload_versionable

        # Necessary to ensure resource and versionable are two distinct objects in memory
        reload_versionable
        reify_self_attributes(resource)
        reify_nested_attributes(resource)
        resource
      end

      def reify_self_attributes(resource)
        attrs = object.slice(*resource.versioned_attribute_names)
        resource.assign_attributes(attrs)
      end

      def reify_nested_attributes(resource)
        resource.versioned_nested_attribute_names.each do |relationship|
          relationship_attrs = object["#{relationship}_attributes"]

          if relationship_attrs.present?
            reflection = resource.association(relationship).reflection

            if reflection.has_one? || reflection.belongs_to?
              resource.send(
                :assign_nested_attributes_for_one_to_one_association,
                relationship.to_sym,
                relationship_attrs
              )
            else
              resource.send(
                :assign_nested_attributes_for_collection_association,
                relationship.to_sym,
                relationship_attrs
              )
            end
          end
        end
      end
    end
  end
end

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
        resource = versionable(true)

        # Reload the versionable so we get a new one
        versionable(true)

        resource.assign_attributes(object.slice(*resource.versioned_attribute_names))
        resource
      end
    end
  end
end

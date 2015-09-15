module ActiveVersioning
  class VersionManager < Struct.new(:record)
    BLACKLISTED_ATTRIBUTES = %w(
      created_at
      updated_at
      published
    )

    def create_draft_from_version(id)
      version = record.versions.find(id)

      ensure_compatibility_with(version)

      new_version        = record.versions.draft.first_or_create(event: 'draft')
      new_version.object = version.object
      new_version.save
    end

    def ensure_compatibility_with(version)
      incompatible_attributes(version).tap do |incompatible_attrs|
        if incompatible_attrs.any?
          raise Errors::IncompatibleVersion.new(record, version), "The given version contains attributes that are no longer compatible with the current schema: #{incompatible_attrs.to_sentence}."
        end
      end
    end

    def incompatible_attributes(version)
      version.object.keys - record.attributes.keys
    end
  end
end

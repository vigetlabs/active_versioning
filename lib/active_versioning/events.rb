module ActiveVersioning
  module Events
    CREATE = 'create'
    DRAFT  = 'draft'
    COMMIT = 'commit'

    ALL = [
      CREATE,
      DRAFT,
      COMMIT
    ]
  end
end

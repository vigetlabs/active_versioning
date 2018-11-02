module ActiveVersioning
  module Test
    class Post < ActiveRecord::Base
      include Model::Versioned

      belongs_to :user
      belongs_to :author, class_name: 'User', foreign_key: 'user_id'
      belongs_to :editor, class_name: 'User', foreign_key: 'user_id'

      validates :title,
                :body,
                presence: true

      accepts_nested_attributes_for :author

      def to_s
        title
      end

      def versioned_nested_attribute_names
        super + %w[author]
      end
    end
  end
end

module ActiveVersioning
  module Test
    class Post < ActiveRecord::Base
      include Model::Versioned

      belongs_to :user

      validates :title,
                :body,
                presence: true

      def to_s
        title
      end
    end
  end
end

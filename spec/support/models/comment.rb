module ActiveVersioning
  module Test
    class Comment < ActiveRecord::Base
      belongs_to :post
    end
  end
end

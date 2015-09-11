module ActiveVersioning
  module Test
    class User < ActiveRecord::Base
      has_many :posts
    end
  end
end

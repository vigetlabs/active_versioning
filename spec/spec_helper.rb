require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rails'
require 'active_record'
require 'database_cleaner'
require 'pry'
require 'generator_spec'
require 'shoulda/matchers'
require 'active_versioning'

%w(
  /fixtures/**/*.rb
  /support/**/*.rb
).each do |file_set|
  Dir[File.dirname(__FILE__) + file_set].each { |file| require file }
end

ActiveVersioning::Test::Database.build

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Stub rails application when necessary.
unless Rails.application.present?
  Rails.application = OpenStruct.new(
    config:      OpenStruct.new(eager_load: false),
    eager_load!: true
  )
end

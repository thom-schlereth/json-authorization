ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "minitest/rails"
require 'minitest/reporters'
require 'database_cleaner'
require 'factory_bot_rails'
require 'rspec/expectations/minitest_integration'
require_relative './support/factory_bot.rb'

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)
module AroundEachTest
  def before_setup
    super
    DatabaseCleaner.clean
    DatabaseCleaner.start
  end
end

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  include FactoryBot::Syntax::Methods
  include AroundEachTest
end

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "simplecov"
require "simplecov-lcov"

SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
)

SimpleCov.start("rails") do
  add_filter "/version/"
end

require File.expand_path("dummy/config/environment.rb", __dir__)

ENV["RAILS_ENV"] ||= "test"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "spec_helper"
require "generator_spec"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#

# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
Dir["support", "*.rb"].each { |file| require file }

RSpec.configure do |config|
  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #

  # config.around(:each) do |example|
  #   DatabaseCleaner.cleaning do
  #     example.run
  #   end
  # end

  config.use_transactional_fixtures = false

  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

# frozen_string_literal: true

require 'support/simplecov'
require 'factory_bot_rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.order = :random
  config.default_formatter = 'doc'
  Kernel.srand config.seed

  config.before(:suite) do
    # Remove test uploaded files before each run
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end

RSpec::Expectations.configuration.on_potential_false_positives = :nothing

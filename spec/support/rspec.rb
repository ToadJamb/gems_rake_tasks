RSpec.configure do |config|
  config.mock_framework = :mocha
  config.order = :random
  #config.include FactoryGirl::Syntax::Methods
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.color_enabled = true

  config.backtrace_clean_patterns = [
    %r|/home/\w+/.rvm/gems/|
  ]

  config.expect_with :stdlib
  config.expect_with :rspec do |conf|
    conf.syntax = :expect
  end
end

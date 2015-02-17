RSpec.configure do |config|
  config.before do
    [
      RakeTasks::System,
    ].each do |klass|
      stub_const klass.to_s, class_double(klass).as_stubbed_const
    end
  end
end

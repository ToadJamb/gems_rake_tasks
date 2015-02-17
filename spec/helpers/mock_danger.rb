module RakeTasksSpecHelpers
  module MockDanger
    def mock_system(method)
      allow(RakeTasks::System).to receive(method)
    end

    def system_expects(method)
      expect(RakeTasks::System).to receive(method)
    end
  end
end

RSpec.configure do |config|
  config.include RakeTasksSpecHelpers::MockDanger
end

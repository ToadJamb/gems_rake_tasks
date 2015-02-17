module RakeTasksSpecHelpers
  module MockDanger
    def mock_util(method)
      allow(Util).to receive(method)
    end
  end
end

RSpec.configure do |config|
  config.include RakeTasksSpecHelpers::MockDanger
end

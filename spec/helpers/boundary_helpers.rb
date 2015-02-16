module RakeTasksRakeHelpers
  module BoundaryHelpers
    def not_implemented(klass, method)
      allow(klass)
        .to receive(method)
        .and_raise NotImplementedError,
          "#{klass}.#{method} has been stubbed as not implemented."
    end
  end
end

RSpec.configure do |config|
  include RakeTasksRakeHelpers::BoundaryHelpers
end

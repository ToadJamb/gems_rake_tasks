module BoundaryHelpers
  def not_implemented(klass, method)
    klass.stubs(method).raises NotImplementedError,
      "#{klass}.#{method} has been stubbed as not implemented."
  end
end

RSpec.configure do |config|
  include BoundaryHelpers
end

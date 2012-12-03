module AssertionHelpers
  if defined?(Test::Unit::Assertions) &&
      !Test::Unit::Assertions.instance_methods.include?('assert_includes')
    def assert_includes(collection, obj, msg = nil)
      msg = message(msg) {
        "Expected #{mu_pp(collection)} to include #{mu_pp(obj)}"
      }
      assert_respond_to collection, :include?
      assert collection.include?(obj), msg
    end
    alias :assert_include :assert_includes
  end
end

RSpec.configure do |config|
  include AssertionHelpers
end

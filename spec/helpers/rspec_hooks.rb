RSpec.configure do |config|
  # Disable all 'dangerous' actions.
  config.before do
    util_methods = Util.methods - Util.superclass.methods
    util_methods.each do |method|
      not_implemented Util, method
    end
  end
end

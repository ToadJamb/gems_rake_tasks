require File.expand_path('spec/helpers/boundary_helpers')

RSpec.configure do |config|
  config.before do
    unsafe_methods = RakeTasks::System.methods - Module.methods
    unsafe_methods.each do |method|
      not_implemented RakeTasks::System, method
    end
  end

  config.before do
    util_methods = Util.methods - Util.superclass.methods
    util_methods.each do |method|
      not_implemented Util, method
    end
  end
end

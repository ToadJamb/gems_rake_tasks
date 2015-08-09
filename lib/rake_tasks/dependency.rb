module RakeTasks
  module Dependency
    extend self

    def loaded?(constant, requirement)
      if ::Kernel::const_defined?(constant.match(/\w+/).to_s)
        return true
      else
        puts "<#{constant}> is not defined.\n"
        puts "Please `require '#{requirement}'` in your application " +
          "before loading the corresponding task."
        return false
      end
    end
  end
end

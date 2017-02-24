# frozen_string_literal: true
module RakeTasks
  module Dependency
    extend self

    def require_politely(lib, title, stream = STDOUT)
      begin
        Kernel.require lib
      rescue LoadError => e
        stream.puts e.message
        stream.puts "#{lib} could not be required."
        stream.puts "Please ensure that #{title} is included in the Gemfile."
      end
    end

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

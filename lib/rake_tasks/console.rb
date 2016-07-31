# frozen_string_literal: true
module RakeTasks
  module Console
    extend self

    def run
      System.system "bundle exec irb -Ilib -r#{lib_name}"
    end

    def lib_name
      return @lib_name if defined?(@lib_name)

      lib = File.basename(System.pwd)

      file = "lib/#{lib}.rb"

      @lib_name = lib if System.file?(file)
      @lib_name ||= nil
    end
  end
end


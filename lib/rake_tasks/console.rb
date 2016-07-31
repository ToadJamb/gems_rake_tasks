# frozen_string_literal: true
module RakeTasks
  module Console
    extend self

    def run
      System.system "bundle exec irb -Ilib -r#{lib_folder}"
    end

    def lib_folder
      return @lib_folder if defined?(@lib_folder)

      @lib_folder = nil
      System.dir_glob('lib/*').each do |lib_item|
        if System.directory?(lib_item) && System.file?("#{lib_item}.rb")
          @lib_folder = File.basename(lib_item)
          break
        end
      end

      return @lib_folder
    end
  end
end

module RakeTasks
  module System
    extend Rake::DSL
    extend self

    def dir(*glob)
      Dir[*glob]
    end

    def dir_glob(*patterns)
      Dir.glob(*patterns)
    end

    def import_task(*task_path)
      import(*task_path)
    end

    def pwd(*args)
      Dir.pwd(*args)
    end

    def file?(*args)
      File.file?(*args)
    end

    def directory?(*args)
      File.directory?(*args)
    end

    def rm(*args)
      FileUtils.rm(*args)
    end

    def open_file(*args, &block)
      File.open(*args, &block)
    end

    def write_file(file_path, array)
      open_file(file_path, 'w') do |file|
        array.each do |element|
          file.puts element
        end
      end
    end

    def load_yaml(*args)
      # Psych must be available on the system,
      # preferably via installing ruby with libyaml already installed.
      Psych.load_file(*args)
    end

    def load_gemspec(*args)
      ::Gem::Specification.load(*args)
    end
  end
end

module RakeTasks
  module System
    extend Rake::DSL
    extend self

    def dir(*glob)
      Dir[*glob]
    end

    def import_task(*task_path)
      import(*task_path)
    end

    def pwd(*args)
      Dir.pwd(*args)
    end
  end
end

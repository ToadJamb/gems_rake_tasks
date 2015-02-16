module RakeTasks
  module Core
    def load_tasks
      task_list.each do |rake_file|
        System.import_task rake_file
      end
    end

    private

    def task_list
      tasks = System.dir(File.join(System.pwd, 'lib', 'tasks', '**', '*.rake'))
      tasks << System.dir(File.join(System.pwd, 'tasks', '**', '*.rake'))
      tasks.flatten
    end
  end
end

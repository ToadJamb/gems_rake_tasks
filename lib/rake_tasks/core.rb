module RakeTasks
  module Core
    def load_tasks
      task_list.each do |rake_file|
        System.import_task rake_file
      end
    end

    private

    def task_list
      System.dir File.join(System.pwd, '**', 'tasks', '**', '*.rake')
    end
  end
end

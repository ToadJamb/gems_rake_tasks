# frozen_string_literal: true
module RakeTasks
  module Core
    def load_tasks
      task_list.each do |rake_file|
        System.import_task rake_file
      end
    end

    def build_default_tasks(
        reqs, specs, local, ci, base = :base, default = :default)
      Rake::Task.define_task base
      Rake::Task[base].clear_prerequisites

      if ci
        Rake::Task.define_task base => (reqs + specs).flatten
      else
        Rake::Task.define_task base => specs
      end

      Rake::Task.define_task default
      Rake::Task[default].clear_prerequisites

      Rake::Task.define_task default => [
        reqs,
        local,
      ].flatten
    end

    private

    def task_list
      tasks = System.dir(File.join(System.pwd, 'lib', 'tasks', '**', '*.rake'))
      tasks << System.dir(File.join(System.pwd, 'tasks', '**', '*.rake'))
      tasks.flatten
    end
  end
end

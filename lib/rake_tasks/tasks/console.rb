if RakeTasks::Console.lib_name
  desc "Start a console " +
    "with the #{RakeTasks::Console.lib_name} environment loaded"
  task :console do
    RakeTasks::Console.run
  end
end

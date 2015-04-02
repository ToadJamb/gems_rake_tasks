if RakeTasks::Console.lib_folder
  desc "Start a console " +
    "with the #{RakeTasks::Console.lib_folder} environment loaded"
  task :console do
    RakeTasks::Console.run
  end
end

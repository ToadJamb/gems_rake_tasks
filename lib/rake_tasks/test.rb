################################################################################
namespace :test do
################################################################################
  test_dir = 'test'
  break unless File.directory?(test_dir)

  # Add a task to run all tests.
  Rake::TestTask.new('all') do |task|
    task.pattern = "#{test_dir}/*_test.rb"
    task.verbose = true
    task.warning = true
  end
  Rake::Task[:all].comment = 'Run all tests'

  file_list = Dir["#{test_dir}/*_test.rb"]

  # Add a distinct test task for each test file.
  file_list.each do |item|
    # Get the name to use for the task by removing '_test.rb' from the name.
    task_name = File.basename(item, '.rb').gsub(/_test$/, '')

    # Add each test.
    Rake::TestTask.new(task_name) do |task|
      task.pattern = item
      task.verbose = true
      task.warning = true
    end
  end

  file_name = File.basename(Dir.getwd) + '_test.rb'

  if File.file?("#{test_dir}/#{file_name}")
    desc "Run a single method in #{file_name}."
    task :method, [:method_name] do |t, args|
      puts `ruby ./#{test_dir}/#{file_name} --name #{args[:method_name]}`
    end
  end
################################################################################
end # :test
################################################################################

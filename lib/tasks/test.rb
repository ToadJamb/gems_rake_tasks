#--
################################################################################
#                      Copyright (C) 2011 Travis Herrick                       #
################################################################################
#                                                                              #
#                                 \v^V,^!v\^/                                  #
#                                 ~%       %~                                  #
#                                 {  _   _  }                                  #
#                                 (  *   -  )                                  #
#                                 |    /    |                                  #
#                                  \   _,  /                                   #
#                                   \__.__/                                    #
#                                                                              #
################################################################################
# This program is free software: you can redistribute it                       #
# and/or modify it under the terms of the GNU Lesser General Public License    #
# as published by the Free Software Foundation,                                #
# either version 3 of the License, or (at your option) any later version.      #
################################################################################
# This program is distributed in the hope that it will be useful,              #
# but WITHOUT ANY WARRANTY;                                                    #
# without even the implied warranty of MERCHANTABILITY                         #
# or FITNESS FOR A PARTICULAR PURPOSE.                                         #
# See the GNU Lesser General Public License for more details.                  #
#                                                                              #
# You should have received a copy of the GNU Lesser General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.        #
################################################################################
#++

if RakeTasks::Tests.exist?
  ############################################################################
  namespace :test do
  ############################################################################
    # Add a task to run all tests.
    Rake::TestTask.new('all') do |task|
      task.test_files = RakeTasks::Tests.file_list
      task.verbose = true
      task.warning = true
    end
    Rake::Task[:all].comment = 'Run all tests'

    # Add tasks for each type of test (unit, integration, performance, etc.).
    RakeTasks::Tests.types.each do |type|
      Rake::TestTask.new(type) do |task|
        task.test_files = RakeTasks::Tests.file_list(type)
        task.verbose = true
        task.warning = true
      end
      Rake::Task[type].comment = "Run #{type} tests"
    end

    # Add a way to call a specific method in a given file.
    RakeTasks::Tests.file_list.each do |file_path|
      desc "Run individual tests in #{file_path}."
      task RakeTasks::Tests.task_name(file_path), [:method_name] do |t, args|
        cmd = ['ruby', "./#{file_path}"]
        if args[:method_name] and !args[:method_name].strip.empty?
          cmd << ['--name', args[:method_name]]
        end
        pid = Process.spawn(*cmd.flatten)
        Process.wait(pid)
      end
    end

    if RakeTasks::Tests::run_rubies?
      desc 'Runs tests against specified rubies and gemsets.'
      task :full do |t|
        RakeTasks::Tests::run_ruby_tests
      end

      desc 'Generates a shell script that will run specs against all rubies'
      task :script do |t|
        RakeTasks::Tests::rubies_shell_script
      end
    end
  ############################################################################
  end # :test
  ############################################################################
end

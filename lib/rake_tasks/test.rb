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

test_dir = 'test'

if File.directory?(test_dir)
  ############################################################################
  namespace :test do
  ############################################################################
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
  ############################################################################
  end # :test
  ############################################################################

  Rake::Task[:default].prerequisites.clear
  task :default => 'test:all'
end

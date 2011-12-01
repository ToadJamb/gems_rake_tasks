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
      task RakeTasks::Tests.task_name(file_path), [:method_name] do |t, args|
        puts `ruby ./#{file_path} --name #{args[:method_name]}`
      end
    end

    if RakeTasks::Tests::test_configs
      desc 'Runs tests against specified rubies and gemsets.'
      task :full do |t|
        base_cmd = ['bash', RakeTasks::SCRIPT_PATH, 'test:all']

        data = []
        RakeTasks::Tests.test_configs.each do |config|
          cmd = base_cmd.dup
          cmd << config[:ruby]
          cmd << "_#{config[:rake]}_" if config[:rake]

          pid = Process.spawn(*cmd, :out => 'out.log', :err => 'err.log')
          Process.wait pid

          if config[:rake]
            puts "#{config[:ruby]} - #{config[:rake]}"
          end

          File.open('out.log', 'r') do |file|
            while line = file.gets
              case line
                when /^[\.EF]*$/, /^Using /
                  puts line.strip unless line.strip.empty?
                when /, \d* assertions[^\/]/
                  puts line.strip
                  data << line.split(', ').map { |x| x.to_i }
              end
            end
          end
        end

        FileUtils.rm 'out.log'
        FileUtils.rm 'err.log'

        tests      = 0
        assertions = 0
        failures   = 0
        errors     = 0
        skips      = 0

        data.each do |status|
          tests      = tests      + status[0]
          assertions = assertions + status[1]
          failures   = failures   + status[2]
          errors     = errors     + status[3]
          skips      = skips      + status[4]
        end

        puts "%d tests, %d assertions, %d failures, %d errors, %d skips" % [
          tests, assertions, failures, errors, skips]
      end
    end
  ############################################################################
  end # :test
  ############################################################################

  Rake::Task[:default].prerequisites.clear
  task :default => 'test:all'
end

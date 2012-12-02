# This file contains the class that assists in setting up test tasks.

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

# The main module for this gem.
module RakeTasks
  # This class assists in setting up test tasks.
  class Tests
      # Returns an array of potential root folder names.
   ROOTS = [
    'test',
    'tests'
   ]

    # The patterns that indicate that a file contains tests.
    PATTERNS = [
      '*_test.rb',
      'test_*.rb',
    ]

    class << self
      # Indicates that tests exist.
      def exist?
        !file_list.empty?
      end

      # Returns an array of test files for the specified group.
      def file_list(group = :all)
        list = []

        PATTERNS.each do |pattern|
          paths(group).each do |path|
            files = Util.dir_glob(File.join(path, pattern))
            list << files
          end
        end

        return list.flatten
      end

      # Convert a path to a file into an appropriate task name.
      # This is done by removing the pattern that is used to indicate
      # it is a test file.
      def task_name(file_path)
        file = File.basename(file_path, '.rb')

        PATTERNS.each do |pattern|
          pattern = pattern.sub(/\.rb$/, '').sub(/\*/, '.+?')

          if file =~ /#{pattern}/
            pattern = pattern.sub(/\.\+\?/, '')
            return file_task(file, pattern)

          end
        end
      end

      # Return an array containing the types of tests that are included.
      def types
        return [] unless root

        types = []

        Util.dir_glob(File.join(root, '**')).each do |path|
          next unless Util.directory?(path)
          types << get_types(path)
        end

        return types.flatten
      end

      def get_types(path)
        types = []
        PATTERNS.each do |pattern|
          next if types.include?(File.basename(path))
          unless Util.dir_glob(File.join(path, pattern)).empty?
            types << File.basename(path)
          end
        end
        types
      end

      # Indicates whether tests can be run against multiple rubies.
      def run_rubies?
        Util.file? rubies_yaml
      end

      # Runs tests against specified ruby/gemset/rake configurations.
      def run_ruby_tests
        parser = Parser.new

        configs = test_configs

        init_rubies configs

        # Loop through the test configurations.
        configs.each do |config|
          puts '*' * 80

          if config[:rake]
            puts "#{config[:ruby]} - #{config[:rake]}"
          end

          cmd = ['bash', RakeTasks::SCRIPTS[:rubies], 'test:all']
          cmd << config[:ruby]
          cmd << config[:rake] if config[:rake]

          # Run the tests.
          pid = Process.spawn(*cmd, :out => 'out.log', :err => 'err.log')
          Process.wait pid

          parse_log parser
        end

        Util.rm 'out.log'
        Util.rm 'err.log'

        puts '*' * 80
        parser.summarize
      end

      # Outputs commands to run all tests.
      def run_rubies_commands
        configs = test_configs

        # Loop through the test configurations.
        cmds = setup_commands(configs)

        run_commands(configs).each do |command|
          cmds << command
        end

        cmds.each do |cmd|
          puts cmd.join(' ')
        end
      end

      # Initialize gemsets for rubies.
      def init_rubies(configs)
        # Loop through the test configurations to initialize gemsets.
        gem_rubies = []
        configs.each do |config|
          next if gem_rubies.include?(config[:ruby])
          gem_rubies << config[:ruby]

          cmd = ['bash', RakeTasks::SCRIPTS[:gemsets]]
          cmd << config[:ruby].split('@')

          pid = Process.spawn(*cmd.flatten)
          Process.wait pid
        end
      end

      # Returns an array of hashes containing all testable rubies/gemsets.
      # ==== Output
      # [Array] The configurations that will be tested.
      def test_configs
        configs = Util.load_yaml(rubies_yaml)
        return [] unless configs.is_a?(Array)

        configs.select! { |c| c['ruby'] || c['gemset'] }

        set_configs configs

        configs
      end

      # Paths to check for test files.
      # Only paths for a specified type will be returned, if specified.
      def paths(group = :all)
        group = group.to_sym
        paths = []

        paths << root if group == :all && root

        types.each do |type|
          if group == type.to_sym || group == :all
            paths << File.join(root, type)
          end
        end

        return paths
      end

      # The root test folder.
      def root
        ROOTS.each do |r|
          return r if Util.directory?(r)
        end
        return
      end

      # Returns the location of the rubies yaml file.
      def rubies_yaml
        return unless root
        File.join('.', root, 'rubies.yml')
      end

      private

      def file_task(file, pattern)
        if pattern.index('_') == 0
          return file.sub(/#{pattern}$/, '')
        else
          return file.sub(/^#{pattern}/, '')
        end
      end

      def parse_log(parser)
        Util.open_file('out.log', 'r') do |file|
          while line = file.gets
            parser.parse line
          end
        end
      end

      def set_configs(configs)
        for i in 0..configs.length - 1 do
          config = configs[i]

          config.keys.each do |key|
            config[key.to_sym] = config[key]
            config.delete key
          end

          if config[:gemset]
            config[:ruby] = "#{config[:ruby]}@#{config[:gemset]}"
          end

          config.delete(:gemset)
        end
      end

      def setup_commands(configs)
        cmds = gemset_create_commands(configs)
        cmds << ['rvm', rvm_rubies(configs), 'do', 'gem', 'install',
          'bundler', '--no-rdoc', '--no-ri']
        cmds << ['rvm', rvm_rubies(configs), 'do', 'bundle', 'install']
        cmds << ['rvm', rvm_rubies(configs), 'do', 'bundle', 'clean', '--force']
        configs.each do |config|
          if config[:rake]
            cmds << ['rvm', config[:ruby], 'do', 'gem', 'install',
              'rake', '-v', config[:rake], '--no-rdoc', '--no-ri']
          end
        end
        cmds
      end

      def run_commands(configs)
        cmds = []
        if configs.any? { |c| c[:rake] }
          configs.each do |config|
            if config[:rake]
              cmds << ['rvm', config[:ruby], 'do', 'rake', "_#{config[:rake]}_"]
            else
              cmds << ['rvm', config[:ruby], 'do', 'bundle', 'exec', 'rake']
            end
          end
        else
          cmds << ['rvm', rvm_rubies(configs), 'do', 'bundle', 'exec', 'rake']
        end
        cmds
      end

      def gemset_create_commands(configs)
        cmds = []
        configs.uniq { |c| c[:ruby] }.each do |config|
          ruby = config[:ruby].sub(/@.*/, '')
          gemset = config[:ruby].sub(/.*@/, '')
          cmds << ['rvm', ruby, 'do', 'rvm', 'gemset', 'create', gemset]
        end
        cmds
      end

      def rvm_rubies(configs)
        configs.uniq { |c| c[:ruby] }.map do |config|
          config[:ruby]
        end.join(',')
      end
    end
  end
end

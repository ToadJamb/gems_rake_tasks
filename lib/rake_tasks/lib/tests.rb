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
    class << self
      # Indicates that tests exist.
      def exist?
        return !Dir[File.join(root, '**')].empty?
      end

      # Returns an array of test files for the specified group.
      def file_list(group = :all)
        group = group.to_sym unless group.is_a?(Symbol)

        list = []

        paths(group).each do |path|
          patterns.each do |pattern|
            files = Dir[File.join(path, pattern)]
            list << files unless files.empty?
          end
        end

        return list.flatten
      end

      # Convert a path to a file into an appropriate task name.
      # This is done by removing the pattern that is used to indicate
      # it is a test file.
      def task_name(file_path)
        file = File.basename(file_path, '.rb')

        patterns.each do |pattern|
          pattern = pattern.sub(/\.rb$/, '').sub(/\*/, '.+?')

          if file =~ /#{pattern}/
            pattern = pattern.sub(/\.\+\?/, '')

            if pattern.index('_') == 0
              return file.sub(/#{pattern}$/, '')
            else
              return file.sub(/^#{pattern}/, '')
            end
          end

        end
      end

      # Return an array containing the types of tests that are included.
      def types
        types = []

        Dir[File.join(root, '**')].each do |path|
          types << File.basename(path) if File.directory?(path)
        end

        return types
      end

      ####################################################################
      private
      ####################################################################

      # The patterns that indicate that a file contains tests.
      def patterns
        [
          '*_test.rb',
          'test_*.rb',
        ]
      end

      # Paths to check for test files.
      # Only paths for a specified type will be returned, if specified.
      def paths(group = :all)
        paths = []

        paths << [root] if group == :all

        types.each do |type|
          if group == type.to_sym || group == :all
            paths << File.join(root, type)
          end
        end

        return paths
      end

      # The root test folder.
      def root
        roots.each do |r|
          unless Dir[r].empty?
            return r
          end
        end
      end

      # Returns an array of potential root folder names.
      def roots
        [
          'test',
          'tests'
        ]
      end
    end
  end
end
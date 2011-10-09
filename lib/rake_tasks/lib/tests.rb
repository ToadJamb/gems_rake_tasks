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
      # TODO : comments.
      def exist?
        # TODO : Use class variables?
        @@exist = !dir(File.join(root, '**')).empty?
        return @@exist
      end

      # TODO : comments.
      def file_list(group = :all)
        group = group.to_sym unless group.is_a?(Symbol)
        list = []
        paths(group).each do |path|
          patterns.each do |pattern|
            files = dir(File.join(path, pattern))
            list << files unless files.empty?
          end
        end
        return list.flatten
      end

      # TODO : comments
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

      # TODO : comments.
      def types
        # TODO : Use class variables?
        types = []
        dir(File.join(root, '**')).each do |path|
          types << File.basename(path) if dir?(path)
        end
        return types
      end

      # TODO : comments.
      def root
        # TODO : Use class variables?
        roots.each do |r|
          unless dir(r).empty?
            @@root = r
            break
          end
        end
        return @@root
      end

      ####################################################################
      private
      ####################################################################

      # TODO : comments.
      def patterns
        [
          '*_test.rb',
          'test_*.rb',
        ]
      end

      # TODO : comments.
      def paths(group = :all)
        paths = []
        paths << [root] if group == :all
        types.each do |type|
          paths << File.join(root, type) if group == type.to_sym || group == :all
        end
        return paths
      end

      # TODO : comments.
      def dir?(path)
        File.directory? path
      end

      # TODO : comments.
      def roots
        [
          'test',
          'tests'
        ]
      end

      # TODO : comments.
      def dir(path)
        Dir[path]
      end
    end
  end
end

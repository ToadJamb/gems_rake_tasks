# This file holds the class that handles gem utilities.

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
  # This class will handle gem utilities.
  class Gem
    class << self
      # Check whether a gem spec file exists for this project.
      def gem_file?
        return !gem_spec_file.nil?
      end

      # Get the gem specification.
      def gem_spec(spec = Kernel.const_get('Gem').const_get('Specification'))
        spec.load(gem_spec_file) if gem_file?
      end

      # Check for a gem spec file.
      def gem_spec_file
        file = File.basename(Dir.getwd) + '.gemspec'
        return nil unless File.file? file
        return file
      end

      # Returns the name and version from the specified gem specification.
      def version(spec = gem_spec)
        if spec.respond_to?(:name) && spec.respond_to?(:version)
          "#{spec.name} version #{spec.version}"
        end
      end

      # Updates the version in the gem specification file.
      def version!(value, spec = gem_spec, temp = Tempfile.new('temp_gem_spec'))
        return if spec.nil?

        begin
          file = File.open(gem_spec_file, 'r')

          while line = file.gets
            if line =~ /version *= *['"]#{spec.version}['"]/
              temp.puts line.sub(/(['"])#{spec.version}(['"])/, "\\1#{value}\\2")
            else
              temp.puts line
            end
          end

          temp.flush

          FileUtils.mv temp.path, gem_spec_file
        rescue Exception => ex
          raise ex
        ensure
          temp.close
          temp.unlink
        end
      end
    end
  end
end

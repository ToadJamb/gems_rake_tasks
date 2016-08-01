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

# frozen_string_literal: true

# The main module for this gem.
module RakeTasks
  # This class will handle gem utilities.
  class Gem
    class Version
      def initialize(string_version)
        @marks = string_version.split('.')
        @marks = @marks.map do |mark|
          if mark.to_i.to_s == mark.to_s
            mark.to_i
          else
            mark
          end
        end
      end

      def next_revision!
        @marks = @marks.select { |m| m.class == Fixnum }
        @marks[-1] += 1
      end

      def next_minor_version!
        @marks = @marks.select { |m| m.class == Fixnum }
        @marks.count.times do |n|
          case n
          when 0
            @marks[n] = @marks[n]
          when 1
            @marks[n] += 1
          else
            @marks[n] = 0
          end
        end
      end

      def next_major_version!
        @marks = @marks.select { |m| m.class == Fixnum }
        @marks.count.times do |n|
          if n == 0
            @marks[n] += 1
          else
            @marks[n] = 0
          end
        end
      end

      def to_s
        @marks.join('.')
      end
    end

    class << self
      # Check whether a gem spec file exists for this project.
      def gemspec_file?
        return !gem_spec_file.nil?
      end

      def gem_file?
        return !gem_file.nil?
      end

      # Returns the gem title.
      # This is the gem name with underscores removed.
      # Wherever an underscore is removed, the next letter is capitalized.
      def gem_title(spec = gem_spec)
        return nil unless spec.respond_to?(:name)
        spec.name.split('_').map { |w| w.capitalize }.join('')
      end

      # Get the gem specification.
      def gem_spec
        System.load_gemspec(gem_spec_file) if gemspec_file?
      end

      # Check for a gem spec file.
      def gem_spec_file
        System.dir_glob('*.gemspec').first
      end

      def gem_file
        @gem_file ||= System.dir_glob('*.gem').first
      end

      # Returns the name and version from the specified gem specification.
      def version(spec = gem_spec)
        if spec.respond_to?(:name) && spec.respond_to?(:version)
          "#{spec.name} version #{spec.version}"
        end
      end

      # Returns the version from the specified gem specification.
      def version_number(spec = gem_spec)
        spec.version.to_s if spec.respond_to?(:version)
      end

      def gem_version
        Version.new version_number
      end

      # Updates the version in the gem specification file.
      def version!(value, spec = gem_spec)
        return unless gem_spec_file

        temp = StringIO.new
        write_temp spec, temp, gem_spec_file, value

        temp.rewind
        write_file gem_spec_file, temp
      end

      def push
        ::Gems.configure do |config|
          config.key = ENV['RUBYGEMS_API_KEY']
        end
        ::Gems.push File.new(gem_file)
      end

      private

      # Write the contents of a stream to a file.
      def write_file(gem_spec_file, stream)
        System.open_file(gem_spec_file, 'w') do |file|
          while line = stream.gets
            file.puts line
          end
        end
      end

      # Write the contents of a file to an in-memory stream object,
      # changing the version.
      def write_temp(spec, stream, gem_spec_file, version)
        System.open_file(gem_spec_file, 'r') do |file|
          while line = file.gets
            if line =~ /version *= *['"]#{spec.version}['"]/
              stream.puts line.sub(/['"].*['"]/, "'#{version}'")
            else
              stream.puts line
            end
          end
        end
      end
    end
  end
end

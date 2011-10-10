# This file holds the class that handles documentation utilities.

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
  # This class will handle documentation utilities.
  class Doc
    # Constructor.
    def initialize(gem_info = RakeTasks::Gem)
      @gem_spec = gem_info.gem_spec
      @gem_title = gem_info.gem_title(@gem_spec)
      @license_path = 'license'
      @contents = nil
    end

    # The default contents for a readme file.
    def readme_contents
      gem_title = @gem_title
      gem_spec = @gem_spec

      @contents ||= %Q{
#{header} Welcome to #{gem_title}

#{gem_spec.description}

#{header} Getting Started

1. Install #{gem_title} at the command prompt if you haven't yet:

  gem install #{gem_spec.name}

2. Require the gem in your Gemfile:

  gem '#{gem_spec.name}', '~> #{gem_spec.version}'

3. Require the gem wherever you need to use it:

  require '#{gem_spec.name}'

#{header} Usage

TODO

#{header} Additional Notes

TODO

#{header} Additional Documentation

rake rdoc:app
#{license_details}}.strip

      return @contents
    end

    ########################################################################
    private
    ########################################################################

    # Header indicator.
    def header
      '=='
    end

    # Compose the license details.
    # This will include links to the license and image,
    # if they exist in the license folder.
    def license_details
      return if @gem_spec.licenses.empty?

      # Set up the header (and other info. that will be the same regardless).
      out = ''
      out += "\n#{header} License\n\n"
      out += "#{@gem_title} is released under the "

      # Get image files.
      images = Dir[
        File.join(@license_path, '*.png'),
        File.join(@license_path, '*.jpg'),
        File.join(@license_path, '*.jpeg'),
        File.join(@license_path, '*.gif')
      ]

      # Get license files (by removing images from all files).
      files = Dir[File.join(@license_path, '*')] - images

      # Find the license file that matches the license.
      found = nil
      files.each do |file|
        next unless File.file?(file)
        if @gem_spec.license.downcase == File.basename(file).downcase
          found = file
          break
        end
      end

      # Add the link to the license file.
      if found
        out += "{#{@gem_spec.license} license}[link:../../#{found}].\n"
      else
        out += "#{@gem_spec.license} license.\n"
      end

      # Find the image file that matches the license.
      found = nil
      images.each do |file|
        next unless File.file?(file)
        if @gem_spec.license.downcase ==
            File.basename(file).sub(/\..+?$/, '').downcase
          found = file
          break
        end
      end

      # Add the link to the image file.
      if found
        out += "\nlink:../../#{found}"
      end

      return out
    end
  end
end

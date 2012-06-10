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
#{header :h1, "Welcome to #{gem_title}"}

#{gem_spec.description}

#{header :h2, 'Getting Started'}

Install #{gem_title} at the command prompt if you haven't yet:

    $ gem install #{gem_spec.name}

Require the gem in your Gemfile:

    gem '#{gem_spec.name}', '~> #{gem_spec.version}'

Require the gem wherever you need to use it:

    require '#{gem_spec.name}'

#{header :h2, 'Usage'}

TODO

#{header :h2, 'Additional Notes'}

TODO

#{header :h2, 'Additional Documentation'}

    $ rake rdoc:app
#{license_details}}.strip

      return @contents
    end

    ########################################################################
    private
    ########################################################################

    # Returns formatted headers.
    def header(type, text = nil)
      case type
      when :h1
        "#{text}\n#{'=' * text.length}"
      when :h2
        "#{text}\n#{'-' * text.length}"
      end
    end

    # Compose the license details.
    def license_details
      return if @gem_spec.licenses.empty?

      %Q{
#{header :h2, 'License'}

#{@gem_title} is released under the #{@gem_spec.licenses.first} license.
}
    end
  end
end

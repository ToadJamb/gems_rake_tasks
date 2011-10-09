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

if RakeTasks::Gem.gem_file?
  ############################################################################
  namespace :doc do
  ############################################################################

    gem_spec_file = RakeTasks::Gem.gem_spec_file
    gem_spec = RakeTasks::Gem.gem_spec

    readme = 'README_GENERATED'

    file readme => gem_spec_file do |t|
      gem_title = camelize(gem_spec.name)
      header = '=='

      content =<<-EOD
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

#{header} License

#{gem_title} is released under the #{gem_spec.license} license.
EOD

      File.open(readme, 'w') do |file|
        file.puts content
      end
    end

    desc "Generate a #{readme} file."
    task :readme => readme

    desc "Removes files associated with generating documentation."
    task :clobber do |t|
      rm_f readme
    end

    def camelize(word)
      result = ''
      word.split('_').each do |section|
        result += section.capitalize
      end
      return result
    end

  ############################################################################
  end # :doc
  ############################################################################

  task :clobber => 'doc:clobber'
end

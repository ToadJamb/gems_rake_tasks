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

if RakeTasks::Gem.gemspec_file?
  ############################################################################
  namespace :doc do
  ############################################################################

    gem_spec_file = RakeTasks::Gem.gem_spec_file

    readme = 'readme.md'
    readme = 'readme_generated.md' if File.file?(readme)

    file readme => gem_spec_file do |t|
      doc_obj = RakeTasks::Doc.new
      RakeTasks::System.write_file readme, doc_obj.readme_contents
    end

    desc "Generate a #{readme} file."
    task :readme => readme

    desc "Removes files associated with generating documentation."
    task :clobber do |t|
      rm_f readme
    end

  ############################################################################
  end # :doc
  ############################################################################

  task :clobber => 'doc:clobber'
end

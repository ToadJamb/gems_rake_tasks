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

current_path = Dir.getwd

Dir.chdir File.expand_path(File.join(File.dirname(__FILE__), '..'))

begin
  require 'bundler'
  Bundler.require

  require 'rake/testtask'
  require 'rdoc/task'
  require 'rake/clean'
  require 'tempfile'
ensure
  Dir.chdir current_path
end

gem_name = File.basename(__FILE__, '.rb')

require_relative File.join(gem_name, 'doc')
require_relative File.join(gem_name, 'rdoc')
require_relative File.join(gem_name, 'gem')
require_relative File.join(gem_name, 'test')

# Include any ruby files in the tasks folder.
task_files = Dir[File.join(Dir.getwd, 'tasks', '*.rb')]

task_files.each do |rake_file|
  require rake_file
end

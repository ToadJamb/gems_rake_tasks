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

require 'rake/testtask'
require 'rdoc/task'
require 'rake/clean'
require 'tempfile'
require 'fileutils'
require 'psych'

gem_name = File.basename(__FILE__, '.rb')

# Require lib files.
Dir[File.join(File.dirname(__FILE__), gem_name, 'lib', '*.rb')].each do |lib|
  require lib
end

# Require tasks.
Dir[File.join(File.dirname(__FILE__), gem_name, '*.rb')].each do |task|
  require task
end

# Include any ruby files in the tasks folder.
Dir[File.join(Dir.getwd, 'tasks', '*.rb')].each do |rake_file|
  require rake_file
end

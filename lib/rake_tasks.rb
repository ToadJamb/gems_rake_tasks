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
require 'fileutils'
require 'psych'

module RakeTasks
  # Contains the full path to the shell script to run tests in other env's.
  SCRIPTS = {
    :rubies  => File.expand_path(File.join(
      File.dirname(__FILE__), 'rake_tasks', 'lib', 'rubies.sh')),
    :gemsets => File.expand_path(File.join(
      File.dirname(__FILE__), 'rake_tasks', 'lib', 'bundle_install.sh')),
  }
end

gem_name = File.basename(__FILE__, '.rb')

task :default

# Require lib files.
Dir[File.join(File.dirname(__FILE__), gem_name, 'lib', '*.rb')].each do |lib|
  require lib
end

# Require tasks.
# These must be required in this order as
# there is an order of precedence for the default task.
# Using a glob, they were being required in different orders
# in different situations.
# Specifically, it was different depending on whether it was
# consumed as an installed gem or pointing to the source.
base = File.dirname(__FILE__)

require File.join(base, 'rake_tasks/rdoc')
require File.join(base, 'rake_tasks/doc')
require File.join(base, 'rake_tasks/gem')
require File.join(base, 'rake_tasks/test')

# Include any ruby files in the tasks folder.
Dir[File.join(Dir.getwd, 'tasks', '*.rb')].each do |rake_file|
  require rake_file
end

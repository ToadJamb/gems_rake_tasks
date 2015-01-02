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
      File.dirname(__FILE__), '..', 'scripts', 'rubies.sh')),
    :gemsets => File.expand_path(File.join(
      File.dirname(__FILE__), '..', 'scripts', 'bundle_install.sh')),
  }
end

gem_name = File.basename(__FILE__, '.rb')
base_path = File.dirname(__FILE__)

# Require base files.
Dir[File.join(base_path, 'base', '*.rb')].each do |base|
  require base
end

# Require files.
Dir[File.join(base_path, gem_name, '*.rb')].each do |lib|
  require lib
end

# Require tasks.
# Using a glob, they were being required in different orders
# in different situations.
# Specifically, it was different depending on whether it was
# consumed as an installed gem or pointing to the source.
require File.join(base_path, 'tasks', 'rdoc')
require File.join(base_path, 'tasks', 'doc')
require File.join(base_path, 'tasks', 'gem')
require File.join(base_path, 'tasks', 'test')

# Include any rake files in tasks folders.
Dir[File.join(Dir.getwd, '**', 'tasks', '**', '*.rake')].each do |rake_file|
  import rake_file
end

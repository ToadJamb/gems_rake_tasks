#--
################################################################################
#                      Copyright (C) 2015 Travis Herrick                       #
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

require 'rspec/core/rake_task'

features     = 'spec/features'
api          = 'spec/api'
integration  = 'spec/integration'
pattern      = '**/*_spec.rb'
unit_exclude = '{features,api,integration}'

namespace :spec do
  if File.directory?(features)
    desc 'Run feature specs'
    RSpec::Core::RakeTask.new :features do |task|
      task.pattern = File.join(features, pattern)
    end
  end

  if File.directory?('spec/api')
    desc 'Run api specs'
    RSpec::Core::RakeTask.new :api do |task|
      task.pattern = File.join(api, pattern)
    end
  end

  if File.directory?(integration)
    desc 'Run integration specs'
    RSpec::Core::RakeTask.new :integration do |task|
      task.pattern = File.join(integration, pattern)
    end
  end

  if File.directory?(features) or
      File.directory?(api) or
      File.directory?(integration)
    desc 'Run unit specs'
    RSpec::Core::RakeTask.new :unit do |task|
      task.exclude_pattern = File.join('spec', unit_exclude, pattern)
    end
  end
end

desc 'Run all specs together'
RSpec::Core::RakeTask.new :specs do
end

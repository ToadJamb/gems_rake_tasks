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

if RakeTasks::Dependency.loaded?('Gems', 'gems') && RakeTasks::Gem.gemspec_file?
  ############################################################################
  namespace :gem do
  ############################################################################

    gem_spec = RakeTasks::Gem.gem_spec
    gem_spec_file = RakeTasks::Gem.gem_spec_file

    file gem_spec.file_name =>
        [gem_spec_file, *Dir['lib/**/*.rb'], 'Gemfile', 'Gemfile.lock'] do |t|
      puts `gem build #{gem_spec_file}`
    end

    desc "Build #{gem_spec.name} gem version #{gem_spec.version}."
    task :build => gem_spec.file_name

    desc "Install the #{gem_spec.name} gem."
    task :install => [gem_spec.file_name] do |t|
      puts `gem install #{gem_spec.file_name} --no-rdoc --no-ri`
    end

    desc "Removes files associated with building " +
      "and installing #{gem_spec.name}."
    task :clobber do |t|
      rm_f gem_spec.file_name
    end

    desc "Removes the gem file, builds, and installs."
    task :generate => ['gem:clobber', gem_spec.file_name, 'gem:install']

    desc "Show/Set the version number."
    task :version, [:number] do |t, args|
      if args[:number].nil?
        puts RakeTasks::Gem.version(gem_spec)
      else
        RakeTasks::Gem.version! args[:number], gem_spec
        gem_spec = RakeTasks::Gem.gem_spec
        puts RakeTasks::Gem.version(gem_spec)
      end
    end

    desc 'Push the gem to rubygems'
    task :push do
      response = RakeTasks::Gem.push
      puts response
      exit(1) unless response.match(/Successfully registered gem/)
    end

  ############################################################################
  end # :gem
  ############################################################################

  task :clobber => 'gem:clobber'
end

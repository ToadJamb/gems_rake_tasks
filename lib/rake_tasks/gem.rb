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

gem_spec_file = RakeTasks::Gem.gem_spec_file

if RakeTasks::Gem.gem_file?
  ############################################################################
  namespace :gem do
  ############################################################################

    gem_spec = Gem::Specification.load(gem_spec_file)

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

    desc "Removes files associated with building and installing #{gem_spec.name}."
    task :clobber do |t|
      rm_f gem_spec.file_name
    end

    desc "Removes the gem file, builds, and installs."
    task :generate => ['gem:clobber', gem_spec.file_name, 'gem:install']

    desc "Show/Set the version number."
    task :version, [:number] do |t, args|
      if args[:number].nil?
        puts "#{gem_spec.name} version #{gem_spec.version}"
      else
        temp_file = Tempfile.new("#{gem_spec.name}_gemspec")

        begin
          File.open(gem_spec_file, 'r') do |file|
            while line = file.gets
              if line =~ /version *= *['"]#{gem_spec.version}['"]/
                temp_file.puts line.sub(
                  /['"]#{gem_spec.version}['"]/, "'#{args[:number]}'")
              else
                temp_file.puts line
              end
            end
          end

          temp_file.flush

          mv temp_file.path, gem_spec_file

        rescue Exception => ex
          raise ex
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end

  ############################################################################
  end # :gem
  ############################################################################

  Rake::Task[:default].prerequisites.clear
  task :default => 'gem:build'

  task :clobber => 'gem:clobber'
end

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

################################################################################
namespace :rdoc do
################################################################################

  # Set the paths used by each of the rdoc options.
  rdoc_files = {
    :all     => [File.join('**', '*.rb')],
    :test    => [File.join('test', 'lib', '**', '*.rb')],
    :app     => [
      '*.rb',
      File.join('lib', '**', '*.rb'),
    ],
  }

  # Base path for the output.
  base_path = 'doc'

  # Loop through the typs of rdoc files to generate an rdoc task for each one.
  rdoc_files.keys.each do |rdoc_task|
    unless Dir[*rdoc_files[rdoc_task]].length == 0
      Rake::RDocTask.new(
          :rdoc         => rdoc_task,
          :clobber_rdoc => "#{rdoc_task}:clobber",
          :rerdoc       => "#{rdoc_task}:force") do |rdtask|
        rdtask.title = ''
        rdtask.rdoc_dir = File.join(base_path, rdoc_task.to_s)
        rdtask.options << '--charset' << 'utf8'
        rdtask.rdoc_files.include 'README', rdoc_files[rdoc_task]
        rdtask.main = 'README'
      end

      Rake::Task[rdoc_task].comment =
        "Generate #{rdoc_task} RDoc documentation."
    end
  end

  CLOBBER.include(base_path)
################################################################################
end # :rdoc
################################################################################

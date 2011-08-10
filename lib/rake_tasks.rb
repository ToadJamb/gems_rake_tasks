require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'
require 'tempfile'

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

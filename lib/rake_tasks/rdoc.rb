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
        rdtask.rdoc_dir = File.join(base_path, rdoc_task.to_s)
        rdtask.options << '--charset' << 'utf8'
        rdtask.rdoc_files.include(rdoc_files[rdoc_task], 'README')
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

task :default => ["rdoc:app"]

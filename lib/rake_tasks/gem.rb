gem_spec_file = "#{File.basename(Dir.getwd)}.gemspec"

if File.file?(gem_spec_file)
  ############################################################################
  namespace :gem do
  ############################################################################

    gem_spec = Gem::Specification.load(gem_spec_file)

    file gem_spec.file_name => [gem_spec_file, *Dir['lib/**/*.rb']] do |t|
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

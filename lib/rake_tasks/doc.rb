gem_spec_file = "#{File.basename(Dir.getwd)}.gemspec"

if File.file?(gem_spec_file)
  ############################################################################
  namespace :doc do
  ############################################################################

    gem_spec = Gem::Specification.load(gem_spec_file)

    readme = 'README_GENERATED'

    file readme => gem_spec_file do |t|
      gem_title = camelize(gem_spec.name)
      header = '=='

      content =<<-EOD
#{header} Welcome to #{gem_title}

#{gem_spec.description}

#{header} Getting Started

1. Install #{gem_title} at the command prompt if you haven't yet:

    gem install #{gem_spec.name}

2. Require the gem in your Gemfile:

    gem '#{gem_spec.name}', '~> #{gem_spec.version}'

3. Require the gem wherever you need to use it:

    require '#{gem_spec.name}'

#{header} Usage

TODO

#{header} Additional Notes

TODO

#{header} Additional Documentation

 rake rdoc:app

#{header} License

#{gem_title} is released under the #{gem_spec.license} license.
EOD

      File.open(readme, 'w') do |file|
        file.puts content
      end
    end

    desc "Generate a #{readme} file."
    task :readme => readme

    desc "Removes files associated with generating documentation."
    task :clobber do |t|
      rm_f readme
    end

    def camelize(word)
      result = ''
      word.split('_').each do |section|
        result += section.capitalize
      end
      return result
    end

  ############################################################################
  end # :doc
  ############################################################################

  task :clobber => 'doc:clobber'
end

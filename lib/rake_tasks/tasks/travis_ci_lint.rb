if RakeTasks::Dependency.loaded?('Travis::Yaml', 'travis/yaml')
  namespace :travis_ci do
    desc 'Lint .travis.yml'
    task :lint do
      parsed_yaml = Travis::Yaml.parse!(File.read('.travis.yml'))
      exit 1 unless parsed_yaml.nested_warnings.empty?
    end
  end
end

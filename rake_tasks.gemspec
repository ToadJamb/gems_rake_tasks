Gem::Specification.new do |s|
  s.name = 'rake_tasks'
  s.version = '0.0.2'

  s.summary = 'Basic rake tasks.'
  s.description = 'RakeTasks contains basic rake tasks ' +
    'for generating documentation, building gems, and running tests. ' +
    'It will also find additional rake files if they are included in a ' +
    'folder named tasks.'

  s.author   = 'Travis Herrick'
  s.email    = 'tthetoad@gmail.com'
  s.homepage = 'http://www.bitbucket.org/ToadJamb/gems_rake_tasks'

  s.license = 'GPLV3'

  s.extra_rdoc_files << 'README'

  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb', '*']
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency 'rake', '~> 0.8.7'

  s.has_rdoc = true
end

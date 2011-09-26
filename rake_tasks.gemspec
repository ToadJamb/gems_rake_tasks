Gem::Specification.new do |s|
  s.name = 'rake_tasks'
  s.version = '1.0.0'

  s.summary = 'Basic rake tasks. You know you want some.'
  s.description =%Q{
RakeTasks provides basic rake tasks for generating documentation,
building and installing gems, and running tests.
It will also load additional rake tasks if they are in a folder named 'tasks'.
mmmm yummy
}.strip

  s.author   = 'Travis Herrick'
  s.email    = 'tthetoad@gmail.com'
  s.homepage = 'http://www.bitbucket.org/ToadJamb/gems_rake_tasks'

  s.license = 'LGPLv3'

  s.extra_rdoc_files << 'README'

  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb', '*']
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency 'rdoc', '~> 3.9.4'
  s.add_dependency 'rake', '~> 0.9.2'

  s.has_rdoc = true
end

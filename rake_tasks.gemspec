# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name = 'rake_tasks'
  s.version = '5.1.1'

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

  s.license = 'LGPL-3.0'

  s.extra_rdoc_files = [
    'readme.markdown',
    'license/gplv3.md',
    'license/lgplv3.md',
  ]

  s.require_paths = ['lib']
  s.files = Dir[
    '*.gemspec',
    'Gemfile',
    'lib/**/*.rb',
    'lib/**/rubies.sh',
    'lib/**/bundle_install.sh',
    'license/*'] -
    Dir['Gemfile.lock']
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency 'rake'

  s.add_development_dependency 'gems'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'cane'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'travis-yaml'
  s.add_development_dependency 'wwtd'
  s.add_development_dependency 'colorize'
end

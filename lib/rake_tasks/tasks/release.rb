# frozen_string_literal: true
if RakeTasks::Gem.gemspec_file?
  desc 'Prepare a gem for release'
  task :release => :default do |task|
    RakeTasks::Release.release
  end
end

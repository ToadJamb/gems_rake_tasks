# frozen_string_literal: true
if RakeTasks::Gem.gemspec_file?
  desc 'Prepare a gem for release'
  task :release do |task|
    RakeTasks::Release.new.release
  end

  desc 'Prepare a gem and repo for release'
  task :full_release do |task|
    RakeTasks::Release.new.full_release
  end
end

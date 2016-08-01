# frozen_string_literal: true
if RakeTasks::Gem.gem_file?
  desc 'Generate all checksums for the current gem file'
  task :checksums do |task|
    RakeTasks::Checksum.checksums
  end
end

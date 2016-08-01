# frozen_string_literal: true
if RakeTasks::Gem.gem_file?
  require 'digest/sha2'

  desc 'Generate a checksum for the current gem file'
  task :checksum do |task|
    RakeTasks::Checksum.save_checksum_for :sha512
  end

  desc 'Generate all checksums for the current gem file'
  task :checksums do |task|
    RakeTasks::Checksum.checksums
  end
end

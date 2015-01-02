if RakeTasks::Gem.gem_file?
  require 'digest/sha2'

  desc 'Generate a checksum for the current gem file'
  task :checksum do |task|
    gem_file = RakeTasks::Gem.gem_file
    checksum = Digest::SHA512.new.hexdigest(File.read(gem_file))
    checksum_file = File.basename(gem_file)
    checksum_path = "checksum/#{checksum_file}.sha512"

    puts checksum

    FileUtils.mkdir_p 'checksum' unless File.directory?('checksum')

    File.open(checksum_path, 'w') do |file|
      file.write checksum
    end
  end
end

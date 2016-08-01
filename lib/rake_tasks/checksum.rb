# frozen_string_literal: true
module RakeTasks
  module Checksum
    extend self

    def checksums
      save_checksum_for :md5
      save_checksum_for :sha256
      save_checksum_for :sha512
    end

    def save_checksum_for(digest)
      checksum = checksum_for(digest)
      save_file_for digest, checksum
    end

    def checksum_for(digest)
      lib =
        case digest
        when :sha256
          Digest::SHA256
        when :sha512
          Digest::SHA512
        when :md5
          Digest::MD5
        end

      hash = lib.file(Gem.gem_file)
      hash.hexdigest
    end

    private

    def save_file_for(digest, checksum)
      gem_file = File.basename(Gem.gem_file)
      path = "checksum/#{gem_file}.#{digest}"

      puts "--- #{digest.to_s.upcase} ---"
      puts checksum

      FileUtils.mkdir_p 'checksum' unless File.directory?('checksum')

      File.open(path, 'w') do |file|
        file.write checksum
      end
    end
  end
end

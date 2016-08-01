# frozen_string_literal: true
module RakeTasks
  class Prompt
    def initialize(prompt, default = nil)
      @prompt   = prompt
      @default  = default
    end

    def get_value
      value = nil
      value = STDIN.cooked { value = Readline::readline(label, false).chomp }
      value = @default if value == '' && @default
      value
    end

    private

    def label
      return "#{@prompt}: " unless @default
      "#{@prompt} [#{@default}]: "
    end
  end

  module Release
    extend self

    def release
      dirty_check

      new_version = get_version
      raise_invalid_version if new_version.to_s.strip.empty?

      update_version new_version
      puts `bundle check`

      puts `gem build #{Gem.gem_spec_file}`
      Checksum.checksums
      update_git(new_version) if File.directory?('.git')

      puts "#{new_version} is ready for release!"
    end

    private

    def update_version(new_version)
      return if new_version == Gem.version_number
      Gem.version! new_version
    end

    def get_version
      version = Gem.gem_version
      version.scrub!
      return version.to_s if is_version?(version)

      version.next_revision!
      return version.to_s if is_version?(version)

      version.next_minor_version!
      return version.to_s if is_version?(version)

      version.next_major_version!
      return version.to_s if is_version?(version)

      version = user_version
    end

    def is_version?(version)
      prompt = "Is the version to release `#{version}`?"
      answer = Prompt.new(prompt, 'n').get_value
      answer == 'y'
    end

    def user_version
      prompt = 'Please enter a new version number to use'
      Prompt.new(prompt).get_value
    end

    def raise_invalid_version
      message = 'No version was specified.'
      raise ArgumentError.new(message)
    end

    def update_git(version)
      `git add checksum`
      `git add Gemfile`
      `git add Gemfile.lock`
      `git add *.gemspec`

      puts `git commit -m "Version #{version}"`
      puts `git tag v#{version}`
    end

    def dirty_check
      return if Dir['*.gem'].empty?
      message = "One or more gems exist in the root folder.\n"
      message += 'Please clean up the folder and try again.'
      raise message
    end
  end
end

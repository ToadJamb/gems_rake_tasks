class Util
  def self.dir_glob(*patterns)
    Dir.glob(*patterns)
  end

  def self.open_file(*args, &block)
    File.open(*args, &block)
  end

  def self.write_file(file_path, array)
    open_file(file_path, 'w') do |file|
      array.each do |element|
        file.puts element
      end
    end
  end

  def self.file?(*args)
    File.file?(*args)
  end

  def self.directory?(*args)
    File.directory?(*args)
  end

  def self.rm(*args)
    FileUtils.rm(*args)
  end

  def self.load_yaml(*args)
    # Psych must be available on the system,
    # preferably via installing ruby with libyaml already installed.
    Psych.load_file(*args)
  end

  def self.load_gemspec(*args)
    Gem::Specification.load(*args)
  end
end

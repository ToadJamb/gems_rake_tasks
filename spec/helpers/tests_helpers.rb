module TestsHelpers
  def test_output
    StringIO.new(
      "#{test_count} tests, 0 assertions, 0 failures, 0 errors, 0 skips")
  end

  def yaml_configs
    [
      # basic
      {in: [
        {'ruby' => '1.9.2', 'gemset' => 'my_gemset'},
        {'ruby' => '1.9.3', 'gemset' => 'my_gems'  },
      ],
      out: [
        {ruby: '1.9.2@my_gemset'},
        {ruby: '1.9.3@my_gems'  },
      ]},

      # with rake
      {in: [
        {'ruby' => '1.9.2', 'gemset' => 'my_gemset', 'rake' => '0.8.7'},
        {'ruby' => '1.9.3', 'gemset' => 'my_gems',   'rake' => '0.9.2'},
      ],
      out: [
        {ruby: '1.9.2@my_gemset', rake: '0.8.7'},
        {ruby: '1.9.3@my_gems',   rake: '0.9.2'},
      ]},

      # ruby only
      {in: [
        {'ruby' => '1.9.2'},
        {'ruby' => '1.9.3'},
      ],
      out: [
        {ruby: '1.9.2'},
        {ruby: '1.9.3'},
      ]},

      # gemset only
      {in: [
        {'gemset' => 'my_gemset'},
        {'gemset' => 'my_gems'},
      ],
      out: [
        {ruby: '@my_gemset'},
        {ruby: '@my_gems'  },
      ]},

      # nonsense
      {in: [
        {'key1' => 'value1'},
        {'key2' => 'value2'},
      ],
      out: []},

      # nothing
      {in: '',
      out: [],}
    ]
  end
  module_function :yaml_configs

  def yaml_config(options = {})
    options = default_options(options)

    keys = options.keys
    keys.each do |key|
      options[key.to_s] = options[key]
    end

    options
  end

  def default_options(options)
    if options[:ruby].nil? && options[:gemset].nil?
      options[:ruby] = "ruby-#{Faker::Lorem.word}"
      options[:gemset] = "gemset_#{Faker::Lorem.word}"
    end
    options
  end

  def yaml_config_list(count = 2, options = {})
    options = default_options(options)

    configs = []
    count.times do |n|
      config_opts = {}
      options.each_key do |key|
        config_opts[key] = "#{options[key]}_#{n + 1}"
      end
      configs << yaml_config(config_opts)
    end

    configs
  end

  def stub_root
    mock_system(:directory?).and_return false
    mock_system(:directory?).with(root).and_return true
  end

  def stub_no_root
    mock_system(:directory?).and_return true
    roots.each do |root_item|
      mock_system(:directory?).with(root_item).and_return false
    end
  end

  def stub_paths
    allow_dir_glob "#{root}/**", paths
    paths.each do |path_item|
      mock_system(:directory?).with(path_item).and_return true
    end
  end

  def stub_test_files
    @files = []

    patterns.each_with_index do |pattern, i|
      stub_test_file_root_glob pattern, i
      stub_test_file_dir_glob pattern, i
    end
  end

  def stub_test_file_root_glob(pattern, i)
    @files << File.join(root, pattern.sub(/\*/, "#{i}_#{Faker::Lorem.word}"))
    allow_dir_glob File.join(root, pattern), [@files.last]
  end

  def stub_test_file_dir_glob(pattern, i)
    paths.each_with_index do |path, j|
      expect(pattern).to match(/\*/)
      add_files_to_test_file_dir_glob path, pattern, rand(4) + 1, i, j
    end
  end

  def add_files_to_test_file_dir_glob(path, pattern, n, i, j)
    n.times do
      @files << File.join(
        path, pattern.sub(/\*/, "#{i}_#{j}_#{Faker::Lorem.word}"))
    end

    allow_dir_glob File.join(path, pattern), @files[-1 * n..-1]
  end

  def allow_dir_glob(glob, result = [])
    mock_system(:dir_glob).with(glob).and_return result
  end
end

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
    Util.stubs(:directory?).with(any_of(*roots)).returns false
    Util.stubs(:directory?).with(root).returns true
  end

  def stub_no_root
    Util.stubs(:directory?).with(any_of(*roots)).returns false
  end

  def stub_paths
    Util.stubs(:directory?).with(any_of(*paths)).returns true
    Util.stubs(:dir_glob).with("#{root}/**").returns paths
  end

  def stub_test_files
    @files = []

    stub_root
    stub_paths

    patterns.each_with_index do |pattern, i|
      stub_test_file_root_glob pattern, i
      stub_test_file_dir_glob pattern, i
    end
  end

  def stub_test_file_root_glob(pattern, i)
    @files << File.join(root, pattern.sub(/\*/, "#{i}_#{Faker::Lorem.word}"))
    Util.stubs(:dir_glob).with(File.join(root, pattern)).returns [@files.last]
  end

  def stub_test_file_dir_glob(pattern, i)
    paths.each_with_index do |path, j|
      assert_match(/\*/, pattern)
      add_files_to_test_file_dir_glob path, pattern, rand(4) + 1, i, j
    end
  end

  def add_files_to_test_file_dir_glob(path, pattern, n, i, j)
    n.times do
      @files << File.join(
        path, pattern.sub(/\*/, "#{i}_#{j}_#{Faker::Lorem.word}"))
    end

    Util.stubs(:dir_glob).with(File.join(path, pattern))
      .returns @files[-1 * n..-1]
  end
end

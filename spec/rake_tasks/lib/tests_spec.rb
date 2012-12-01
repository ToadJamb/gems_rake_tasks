require_relative '../../spec_helper'

describe RakeTasks::Tests do
  include TestsHelpers

  let(:klass) { RakeTasks::Tests }

  roots = [
    'test',
    'tests',
  ]
  let(:roots) { roots }

  patterns = [
    '*_test.rb',
    'test_*.rb',
  ]
  let(:patterns) { patterns }

  let(:subfolders) { Faker::Lorem.words(8).uniq }
  let(:root) { roots.sample }
  let(:paths) { subfolders.map { |f| "#{root}/#{f}" } }
  let(:yaml_path) { File.join('.', root, 'rubies.yml') }

  let(:pids) do
    pids = []
    yaml_configs.count.times do
      pid = rand(98) + 1
      while pids.include?(pid)
        pid = rand(98) + 1
      end
      pids << pid
    end
    pids
  end

  describe '::ROOTS' do
    it 'contains at least one element' do
      assert klass::ROOTS.count > 0
    end

    it 'has the correct number of elements' do
      assert_equal roots.count, klass::ROOTS.count
    end

    roots.each do |root|
      it "contains #{root.inspect}" do
        assert_include klass::ROOTS, root
      end
    end
  end

  describe '::PATTERNS' do
    it 'contains at least one element' do
      assert klass::PATTERNS.count > 0
    end

    it 'has the correct number of elements' do
      assert_equal patterns.count, klass::PATTERNS.count
    end

    patterns.each do |pattern|
      it "contains #{pattern.inspect}" do
        assert_include klass::PATTERNS, pattern
      end
    end
  end

  describe '::task_name' do
    test_name = Faker::Lorem.word
    [
      [test_name, "test/unit/#{test_name}_test.rb"],
      [test_name, "test/unit/test_#{test_name}.rb"],
      ["#{test_name}_tests", "test/unit/#{test_name}_tests_test.rb"],
    ].each do |task|
      context "given a file of #{task.last}" do
        it "returns #{task.first}" do
          assert_equal task.first, klass.task_name(task.last)
        end
      end
    end
  end

  describe '::exist?' do
    context 'given no root folder' do
      before { stub_no_root }
      before { refute Util.directory?(root) }

      it 'returns false' do
        assert_equal false, klass.exist?
      end
    end

    context 'given a root folder' do
      before { stub_root }

      before { assert_equal true, Util.directory?(root) }

      context 'given no test files' do
        before do
          Util.stubs(:directory?).with(any_of(*paths)).returns true
          Util.stubs(:dir_glob).with("#{root}/**").returns paths

          patterns.each do |pattern|
            Util.stubs(:dir_glob).with(File.join(root, pattern)).returns []

            paths.each do |path|
              Util.stubs(:dir_glob).with(File.join(path, pattern)).returns []
            end
          end
        end

        before { assert_empty klass.file_list }

        it 'returns false' do
          assert_equal false, klass.exist?
        end
      end

      context 'given test files' do
        before { stub_test_files }

        before do
          patterns.each do |pattern|
            refute_empty Util.dir_glob(File.join(root, pattern))

            paths.each do |path|
              refute_empty Util.dir_glob(File.join(path, pattern))
            end
          end
        end

        it 'returns true' do
          assert_equal true, klass.exist?
        end
      end
    end
  end

  describe '::root' do
    before { stub_no_root }

    context 'given a root test folder exists' do
      before { Util.stubs(:directory?).with(root).returns true }

      before do
        root_count = 0
        roots.each do |root|
          root_count += 1 if Util.directory?(root)
        end
        assert_equal 1, root_count
      end

      it 'returns the folder name' do
        assert_equal root, klass.root
      end
    end

    context 'given a root folder does not exist' do
      before { refute roots.any? { |r| Util.directory?(r) } }

      it 'returns nil' do
        assert_nil klass.root
      end
    end

    context 'given multiple root folders exist' do
      before do
        roots.each { |r| Util.stubs(:directory?).with(r).returns true }
      end

      before { assert klass::ROOTS.count > 1 }

      before do
        klass::ROOTS.each do |root|
          assert Util.directory?(root)
        end
      end

      it 'returns the first one' do
        assert_equal klass::ROOTS.first, klass.root
      end
    end
  end

  describe '::file_list' do
    before { stub_test_files }

    context 'by default' do
      it 'returns files in the test folder' do
        assert_equal @files, klass.file_list
      end
    end

    context 'given a file type' do
      let(:type) { subfolders.sample.to_sym }
      let(:type_files) { @files.select { |f| f.match(%r|^#{root}/#{type}/|) } }

      before { assert type_files.count > 0 }

      it 'returns only files for that type' do
        assert_equal type_files, klass.file_list(type)
      end
    end
  end

  describe '::paths' do
    before { stub_test_files }

    it 'returns the paths that contain test files' do
      assert_equal [root].push(paths).flatten, klass.paths
    end

    context 'given a specific type' do
      let(:path) { paths.sample }
      let(:type) { File.basename(path).to_sym }

      context 'given the type is a symbol' do
        before { assert_kind_of Symbol, type }

        it 'returns the path for that type' do
          assert_equal [path], klass.paths(type)
        end
      end

      context 'given the type is a string' do
        let(:type) { File.basename(path) }

        before { assert_kind_of String, type }

        it 'returns the path for that type' do
          assert_equal [path], klass.paths(type)
        end
      end

      context 'given all types are specified' do
        let(:type) { :all }

        before { assert_equal :all, type }

        it 'includes the root path' do
          assert_include klass.paths(type), root
        end

        it 'includes all paths' do
          assert_equal [root].push(paths).flatten, klass.paths(type)
        end
      end
    end

    context 'given no root folder' do
      before { stub_no_root }
      before { refute Util.directory?(root) }

      it 'returns an empty array' do
        assert_empty klass.paths
      end
    end
  end

  describe '::types' do
    before do
      Util.stubs directory?: false
      Util.stubs(:directory?).with(root).returns true
      Util.stubs(:dir_glob).with("#{root}/**").returns paths
    end

    context 'given subfolders of the test folder' do
      before do
        Util.stubs(:directory?).with(any_of(*paths)).returns true
      end

      before do
        assert subfolders.count > 1
        subfolders.each do |folder|
          assert Util.directory?("#{root}/#{folder}")
        end
      end

      context 'given files match test file patterns' do
        before do
          paths.each do |path|
            patterns.each do |pattern|
              Util.stubs(:dir_glob).with(File.join(path, pattern)).returns [1]
            end
          end
        end

        before do
          paths.each do |path|
            assert Util.directory?(path)
            patterns.each do |pattern|
              refute_empty Util.dir_glob(File.join(path, pattern))
            end
          end
        end

        it 'returns the subfolder names' do
          assert_equal subfolders, klass.types
        end
      end

      context 'given no files match test file patterns' do
        before do
          patterns.each do |pattern|
            paths.each do |path|
              Util.stubs(:dir_glob).with(File.join(path, pattern)).returns []
            end
          end
        end

        before do
          paths.each do |path|
            assert Util.directory?(path)
            patterns.each do |pattern|
              assert_empty Util.dir_glob(File.join(path, pattern))
            end
          end
        end

        it 'returns an empty array' do
          assert_empty klass.types
        end
      end
    end

    context 'given only files in the test folder' do
      before do
        Util.stubs(:dir_glob).with("#{root}/**").returns paths
      end

      before do
        paths.each do |folder|
          refute Util.directory?(folder)
        end
      end

      it 'returns an empty array' do
        assert_empty klass.types
      end
    end

    context 'given no root folder' do
      before { stub_no_root }
      before { refute Util.directory?(root) }

      it 'returns an empty array' do
        assert_empty klass.types
      end
    end
  end

  describe '::run_rubies?' do
    context 'given no root folder' do
      before { stub_no_root }
      before { Util.stubs(:file?).with(any_of(nil, '')).returns false }
      before { refute roots.any? { |r| Util.directory?(r) } }

      it 'returns false' do
        refute klass.run_rubies?
      end
    end

    context 'given a root folder' do
      before { stub_root }
      before { Util.stubs(:file?).with(yaml_path).returns true }
      before { assert Util.directory?(root) }

      it 'returns false' do
        assert klass.run_rubies?
      end
    end
  end

  describe '::rubies_yaml' do
    context 'given a root folder' do
      before { stub_root }

      before { assert_equal true, Util.directory?(root) }

      it 'returns the path to the yaml file' do
        assert_equal yaml_path, klass.rubies_yaml
      end
    end
  end

  describe '::run_ruby_tests' do
    let(:yaml_configs) { yaml_config_list(3) }
    let(:seperator) { '*' * 80 }
    let(:seperator_count) { yaml_configs.count + 1 }
    let(:test_count) { rand(9) + 1 }

    before { reset_io }
    before { stub_root }

    before { Util.stubs(:load_yaml).with(yaml_path).returns yaml_configs }
    before { klass.expects(:init_rubies).with kind_of(Array) }
    before { Util.expects(:rm).with 'out.log' }
    before { Util.expects(:rm).with 'err.log' }
    before do
      yaml_configs.count.times do
        Util.expects(:open_file).with('out.log', 'r').yields test_output
      end
    end

    context 'by default' do
      it 'runs all specs' do
        yaml_configs.each_with_index do |config, i|
          command = ['bash', RakeTasks::SCRIPTS[:rubies], 'test:all']
          command << config[:ruby]

          Process.expects(:spawn).with(*command, out: 'out.log', err: 'err.log')
            .returns pids[i]
          Process.expects(:wait).with pids[i]
        end

        wrap_output { klass.run_ruby_tests }

        assert_equal seperator_count, out.scan(seperator).count
        assert_match "#{test_count * yaml_configs.count} tests", out
      end
    end

    context 'given rake versions are specified' do
      let(:yaml_configs) { yaml_config_list(3, rake: Faker::Lorem.word) }
      it 'runs all specs' do
        yaml_configs.each_with_index do |config, i|
          command = ['bash', RakeTasks::SCRIPTS[:rubies], 'test:all']
          command << config[:ruby]
          command << config[:rake]

          Process.expects(:spawn).with(*command, out: 'out.log', err: 'err.log')
            .returns pids[i]
          Process.expects(:wait).with pids[i]
        end

        wrap_output { klass.run_ruby_tests }

        yaml_configs.each do |config|
          assert_match "#{config[:ruby]} - #{config[:rake]}", out
        end
      end
    end
  end

  describe '::test_configs' do
    before { stub_root }

    TestsHelpers.yaml_configs.each do |yaml_hash|
      context "given #{yaml_hash[:in].inspect}" do
        before do
          Util.stubs(:load_yaml).with(yaml_path).returns yaml_hash[:in].dup
        end

        it "returns #{yaml_hash[:out].inspect}" do
          assert_equal yaml_hash[:out], klass.test_configs
        end
      end
    end
  end

  describe '::init_rubies' do
    let(:yaml_configs) do
      fakers = []
      8.times do |n|
        word = Faker::Lorem.word
        while fakers.include?(word)
          word = Faker::Lorem.word
        end
        fakers << word
      end

      ruby = fakers.first
      [
        yaml_config(ruby: ruby, rake: fakers[1]),
        yaml_config(ruby: ruby, gemset: fakers[2]),
        yaml_config(ruby: ruby, rake: fakers[3]),
        yaml_config(gemset: fakers[4]),
        yaml_config(ruby: fakers[5]),
        yaml_config(ruby: fakers[6], gemset: fakers[7])
      ]
    end

    before { stub_root }
    before { Util.stubs(:load_yaml).with(yaml_path).returns yaml_configs }

    context 'by default' do
      it 'initializes rubies' do
        configs = klass.test_configs

        rubies = []
        configs.each_with_index do |config, i|
          next if rubies.include?(config[:ruby])
          rubies << config[:ruby]

          command = ['bash', RakeTasks::SCRIPTS[:gemsets]]
          command << config[:ruby].split('@')

          Process.expects(:spawn).with(*command.flatten).returns pids[i]
          Process.expects(:wait).with pids[i]
        end

        klass.init_rubies configs
      end
    end
  end
end

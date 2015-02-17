require 'spec_helper'

RSpec.describe RakeTasks::Tests do
  include TestsHelpers

  root_list = [
    'test',
    'tests',
    'spec',
  ]
  let(:roots) { root_list }

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
    list = []
    yaml_configs.count.times do
      pid = rand(98) + 1
      while list.include?(pid)
        pid = rand(98) + 1
      end
      list << pid
    end
    list
  end

  describe '::ROOTS' do
    it 'contains at least one element' do
      expect(described_class::ROOTS.count).to be > 0
    end

    it 'has the correct number of elements' do
      expect(described_class::ROOTS.count).to eq roots.count
    end

    root_list.each do |root_item|
      it "contains #{root_item.inspect}" do
        expect(described_class::ROOTS).to include root_item
      end
    end
  end

  describe '::PATTERNS' do
    it 'contains at least one element' do
      expect(described_class::PATTERNS.count).to be > 0
    end

    it 'has the correct number of elements' do
      expect(described_class::PATTERNS.count).to eq patterns.count
    end

    patterns.each do |pattern|
      it "contains #{pattern.inspect}" do
        expect(described_class::PATTERNS).to include pattern
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
          expect(described_class.task_name(task.last)).to eq task.first
        end
      end
    end
  end

  describe '::exist?' do
    context 'given no root folder' do
      before { stub_no_root }
      before { expect(Util.directory?(root)).to eq false }

      it 'returns false' do
        expect(described_class.exist?).to eq false
      end
    end

    context 'given a root folder' do
      before { stub_root }
      before { stub_paths }

      before { expect(patterns.count).to be > 0 }

      before { expect(Util.directory?(root)).to eq true }

      context 'given no test files' do
        before do
          patterns.each do |pattern|
            allow(Util)
              .to receive(:dir_glob)
              .with(File.join(root, pattern))
              .and_return []

            paths.each do |path_item|
              allow(Util)
                .to receive(:dir_glob)
                .with(File.join(path_item, pattern))
                .and_return []
            end
          end
        end

        before { expect(described_class.file_list).to eq [] }

        it 'returns false' do
          expect(described_class.exist?).to eq false
        end
      end

      context 'given test files' do
        before { stub_test_files }

        before do
          patterns.each do |pattern|
            expect(Util.dir_glob(File.join(root, pattern)).empty?).to eq false

            paths.each do |path_item|
              expect(Util.dir_glob(File.join(path_item, pattern)).empty?)
                .to eq false
            end
          end
        end

        it 'returns true' do
          expect(described_class.exist?).to eq true
        end
      end
    end
  end

  describe '::root' do
    before { stub_no_root }

    context 'given a root test folder exists' do
      before { allow(Util).to receive(:directory?).with(root).and_return true }

      before do
        root_count = 0
        roots.each do |root_item|
          root_count += 1 if Util.directory?(root_item)
        end
        expect(root_count).to eq 1
      end

      it 'returns the folder name' do
        expect(described_class.root).to eq root
      end
    end

    context 'given a root folder does not exist' do
      before { expect(roots.any? { |r| Util.directory?(r) }).to eq false }

      it 'returns nil' do
        expect(described_class.root).to eq nil
      end
    end

    context 'given multiple root folders exist' do
      before do
        roots.each do |root_item|
          allow(Util).to receive(:directory?).with(root_item).and_return true
        end
      end

      before { expect(described_class::ROOTS.count).to be > 1 }

      before do
        described_class::ROOTS.each do |root_item|
          expect(Util.directory?(root_item)).to eq true
        end
      end

      it 'returns the first one' do
        expect(described_class.root).to eq described_class::ROOTS.first
      end
    end
  end

  describe '::file_list' do
    before { stub_root }
    before { stub_paths }
    before { stub_test_files }

    context 'by default' do
      it 'returns files in the test folder' do
        expect(described_class.file_list).to eq @files
      end
    end

    context 'given a file type' do
      let(:type) { subfolders.sample.to_sym }
      let(:type_files) { @files.select { |f| f.match(%r|^#{root}/#{type}/|) } }

      before { expect(type_files.count).to be > 0 }

      it 'returns only files for that type' do
        expect(described_class.file_list(type)).to eq type_files
      end
    end
  end

  describe '::paths' do
    before { stub_root }
    before { stub_paths }
    before { stub_test_files }

    it 'returns the paths that contain test files' do
      expect(described_class.paths).to eq [root].push(paths).flatten
    end

    context 'given a specific type' do
      let(:path) { paths.sample }
      let(:type) { File.basename(path).to_sym }

      context 'given the type is a symbol' do
        before { expect(type).to be_a Symbol }

        it 'returns the path for that type' do
          expect(described_class.paths(type)).to eq [path]
        end
      end

      context 'given the type is a string' do
        let(:type) { File.basename(path) }

        before { expect(type).to be_a String }

        it 'returns the path for that type' do
          expect(described_class.paths(type)).to eq [path]
        end
      end

      context 'given all types are specified' do
        let(:type) { :all }

        before { expect(type).to eq :all }

        it 'includes the root path' do
          expect(described_class.paths(type)).to include root
        end

        it 'includes all paths' do
          expect(described_class.paths(type)).to eq [root].push(paths).flatten
        end
      end
    end

    context 'given no root folder' do
      before { stub_no_root }
      before { expect(Util.directory?(root)).to eq false }

      it 'returns an empty array' do
        expect(described_class.paths).to eq []
      end
    end
  end

  describe '::types' do
    before { stub_root }

    context 'given subfolders of the test folder' do
      before { stub_paths }

      before do
        expect(subfolders.count).to be > 1
        subfolders.each do |folder|
          expect(Util.directory?("#{root}/#{folder}")).to eq true
        end
      end

      context 'given files match test file patterns' do
        before do
          paths.each do |path|
            patterns.each do |pattern|
              allow(Util)
                .to receive(:dir_glob)
                .with(File.join(path, pattern))
                .and_return [1]
            end
          end
        end

        before do
          paths.each do |path|
            expect(Util.directory?(path)).to eq true
            patterns.each do |pattern|
              expect(Util.dir_glob(File.join(path, pattern)).empty?).to eq false
            end
          end
        end

        it 'returns the subfolder names' do
          expect(described_class.types).to eq subfolders
        end
      end

      context 'given no files match test file patterns' do
        before do
          patterns.each do |pattern|
            paths.each do |path|
              allow(Util)
                .to receive(:dir_glob)
                .with(File.join(path, pattern))
                .and_return []
            end
          end
        end

        before do
          paths.each do |path|
            expect(Util.directory?(path)).to eq true
            patterns.each do |pattern|
              expect(Util.dir_glob(File.join(path, pattern))).to eq []
            end
          end
        end

        it 'returns an empty array' do
          expect(described_class.types).to eq []
        end
      end
    end

    context 'given only files in the test folder' do
      before do
        allow(Util).to receive(:dir_glob).with("#{root}/**").and_return paths
      end

      before do
        paths.each do |folder|
          expect(Util.directory?(folder)).to eq false
        end
      end

      it 'returns an empty array' do
        expect(described_class.types).to eq []
      end
    end

    context 'given no root folder' do
      before { stub_no_root }
      before { expect(Util.directory?(root)).to eq false }

      it 'returns an empty array' do
        expect(described_class.types).to eq []
      end
    end
  end

  describe '::run_rubies?' do
    context 'given no root folder' do
      before { stub_no_root }
      before do
        [nil, ''].each do |file_name|
          allow(Util)
            .to receive(:file?)
            .with(file_name)
            .and_return false
        end
      end

      before { expect(roots.any? { |r| Util.directory?(r) }).to eq false }

      it 'returns false' do
        expect(described_class.run_rubies?).to eq false
      end
    end

    context 'given a root folder' do
      before { stub_root }
      before { allow(Util).to receive(:file?).with(yaml_path).and_return true }
      before { expect(Util.directory?(root)).to eq true }

      it 'returns true' do
        expect(described_class.run_rubies?).to eq true
      end
    end
  end

  describe '::rubies_yaml' do
    context 'given a root folder' do
      before { stub_root }

      before { expect(Util.directory?(root)).to eq true }

      it 'returns the path to the yaml file' do
        expect(described_class.rubies_yaml).to eq yaml_path
      end
    end
  end

  describe '::run_ruby_tests' do
    # Increase the yaml_config count to see test_output not get cached/rewound.
    let(:yaml_configs) { yaml_config_list 1 }
    let(:seperator) { '*' * 80 }
    let(:seperator_count) { yaml_configs.count + 1 }
    let(:test_count) { rand(9) + 1 }

    before { reset_io }
    before { stub_root }

    before do
      allow(Util).to receive(:load_yaml).with(yaml_path).and_return yaml_configs

      expect(described_class).to receive(:init_rubies).with kind_of(Array)
      expect(Util).to receive(:rm).with 'out.log'
      expect(Util).to receive(:rm).with 'err.log'
    end

    before do
      yaml_configs.count.times do
        allow(Util)
          .to receive(:open_file)
          .with('out.log', 'r')
          .and_yield test_output
      end
    end

    context 'by default' do
      it 'runs all specs' do
        yaml_configs.each_with_index do |config, i|
          command = ['bash', RakeTasks::SCRIPTS[:rubies], 'test:all']
          command << "#{config[:ruby]}@#{config[:gemset]}"

          expect(Process)
            .to receive(:spawn)
            .with(*command, out: 'out.log', err: 'err.log')
            .and_return pids[i]
          expect(Process).to receive(:wait).with pids[i]
        end

        wrap_output { described_class.run_ruby_tests }

        expect(out.scan(seperator).count).to eq seperator_count
        expect(out).to match("#{test_count * yaml_configs.count} tests")
      end
    end

    context 'given rake versions are specified' do
      let(:yaml_configs) { yaml_config_list(3, rake: Faker::Lorem.word) }
      it 'runs all specs' do
        yaml_configs.each_with_index do |config, i|
          command = ['bash', RakeTasks::SCRIPTS[:rubies], 'test:all']
          command << "#{config[:ruby]}@#{config[:gemset]}"
          command << config[:rake]

          expect(Process)
            .to receive(:spawn)
            .with(*command, out: 'out.log', err: 'err.log')
            .and_return pids[i]
          expect(Process).to receive(:wait).with pids[i]
        end

        wrap_output { described_class.run_ruby_tests }

        yaml_configs.each do |config|
          expect(out).to match("#{config[:ruby]} - #{config[:rake]}")
        end
      end
    end
  end

  describe '::test_configs' do
    before { stub_root }

    TestsHelpers.yaml_configs.each do |yaml_hash|
      context "given #{yaml_hash[:in].inspect}" do
        before do
          allow(Util)
            .to receive(:load_yaml)
            .with(yaml_path)
            .and_return yaml_hash[:in].dup
        end

        it "returns #{yaml_hash[:out].inspect}" do
          expect(described_class.test_configs).to eq yaml_hash[:out]
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

    before do
      allow(Util)
        .to receive(:load_yaml)
        .with(yaml_path)
        .and_return yaml_configs
    end

    context 'by default' do
      it 'initializes rubies' do
        configs = described_class.test_configs

        rubies = []
        configs.each_with_index do |config, i|
          next if rubies.include?(config[:ruby])
          rubies << config[:ruby]

          command = ['bash', RakeTasks::SCRIPTS[:gemsets]]
          command << config[:ruby].split('@')

          expect(Process)
            .to receive(:spawn)
            .with(*command.flatten)
            .and_return pids[i]

          expect(Process).to receive(:wait).with pids[i]
        end

        described_class.init_rubies configs
      end
    end
  end

  describe '::rubies_shell_script' do
    context 'given rubies and gemsets' do
      let(:yaml_configs) { yaml_config_list 2 }
      let(:uniq_configs) do
        yaml_configs.uniq { |c| "#{c[:ruby]}@#{c[:gemset]}" }
      end
      let(:rvm_rubies) { uniq_configs.map { |c| c[:ruby] }.join(',') }
      let(:rvm_ruby_list) do
        uniq_configs.map { |c| c[:ruby].sub(/@.*/, '') }.join(',')
      end
      let(:rvm) { "rvm #{rvm_rubies} do" }
      let(:bundler_install) { "#{rvm} gem install bundler --no-rdoc --no-ri" }
      let(:bundle_clean) { "#{rvm} bundle clean --force" }
      let(:bundle_install) { "#{rvm} bundle install" }
      let(:gemset_creates) do
        yaml_configs.map do |config|
          ruby = config[:ruby].sub(/@.*/, '')
          gemset = config[:ruby].sub(/.*@/, '')
          "rvm #{ruby} do rvm gemset create #{gemset}"
        end
      end
      let(:rake) { "#{rvm} bundle exec rake" }
      let(:output) { @output }
      let(:offset) { yaml_configs.count + 1 }
      let(:ruby_shell_script) { 'rubies.sh' }
      let(:rakes) do
        yaml_configs.map do |config|
          if config[:rake]
            [
              "echo ruby: #{config[:ruby]} / rake: #{config[:rake]}",
              "rvm #{config[:ruby]} do rake _#{config[:rake]}_",
            ]
          else
            "rvm #{config[:ruby]} do bundle exec rake"
          end
        end.flatten
      end

      before { reset_io }
      before { stub_root }

      before do
        allow(Util)
          .to receive(:load_yaml)
          .with(yaml_path)
          .and_return yaml_configs
      end

      before do
        allow(Util)
          .to receive(:write_file)
          .with(ruby_shell_script, anything) do |file, content|
            @output = content
          end
      end

      before do
        expect(yaml_configs.all? { |c| c[:ruby] && c[:gemset] }).to eq true
      end

      it 'tells the shell to exit on error' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output.first).to eq 'set -e'
      end

      it 'creates the gemset' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output[1]).to eq gemset_creates.first

        gemset_creates.each_with_index do |gemset_create, i|
          expect(output[i + 1]).to eq gemset_create
        end
      end

      it 'installs bundler' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output[0 + offset]).to eq bundler_install
      end

      it 'installs gems' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output[1 + offset]).to eq bundle_install
      end

      it 'cleans up gems' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output[2 + offset]).to eq bundle_clean
      end

      it 'runs rake' do
        described_class.rubies_shell_script
        expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
        expect(output.last).to eq rake
      end

      it 'does not install rake' do
        described_class.rubies_shell_script
        expect(output.any? { |line| line.index('gem install rake') })
          .to eq false
      end

      context 'given rake is specified for all configs' do
        let(:yaml_configs) { yaml_config_list 2, rake: Faker::Lorem.word }
        let(:rake_installs) do
          yaml_configs.map do |config|
            "rvm #{config[:ruby]} do gem install " +
              "rake -v #{config[:rake]} --no-rdoc --no-ri"
          end
        end
        let(:echoes) { rakes.select { |r| r.match(/^echo ruby: /) } }

        before { expect(yaml_configs.all? { |c| c[:rake] }).to eq true }

        it 'installs the appropriate rake version' do
          described_class.rubies_shell_script
          expect(rvm_rubies.scan('@').count).to eq yaml_configs.count

          index = output.index(rake_installs.first)
          expect(index).to eq 3 + offset

          yaml_configs.each_with_index do |config, i|
            expect(output[index + i]).to eq rake_installs[i]
          end
        end

        it 'runs rake without bundle exec' do
          described_class.rubies_shell_script
          expect(rvm_rubies.scan('@').count).to eq yaml_configs.count

          expect(output.last).to eq rakes.last

          yaml_configs.reverse.each_with_index do |config, i|
            index = -(i + 1)
            expect(output[index]).to eq rakes[index]
          end
        end

        it 'echoes the ruby/rake combination' do
          described_class.rubies_shell_script
          expect(rvm_rubies.scan('@').count).to eq yaml_configs.count
          expect(echoes.count).to be > 0
          echoes.each do |echo|
            expect(output).to include echo
          end
        end

        context 'given the same ruby/gemset combination is specified' do
          let(:yaml_configs) do
            ruby = "ruby_#{Faker::Lorem.word}"
            gemset = "gemset_#{Faker::Lorem.word}"
            rake = "rake_#{Faker::Lorem.word}"

            [
              yaml_config(ruby: ruby, gemset: gemset, rake: "#{rake}_1"),
              yaml_config(ruby: ruby, gemset: gemset, rake: "#{rake}_2"),
            ]
          end

          let(:rvm_rubies) { uniq_configs.map { |c| c[:ruby] }.join(',') }

          before { expect(uniq_configs.count).to_not eq yaml_configs.count }

          it 'creates the gemset once' do
            described_class.rubies_shell_script
            expect(rvm_rubies.scan('@').count).to eq uniq_configs.count
            expect(output[1]).to eq gemset_creates.first

            gemset_creates.each do |gemset_create|
              expect(output.count{ |l| l.match(gemset_create) }).to eq 1
            end
          end

          it 'does not repeat ruby/gemset combinations' do
            described_class.rubies_shell_script
            expect(rvm_rubies.scan('@').count).to eq uniq_configs.count

            output.each do |line|
              if !line.match('rake') && !line.match(/rvm gemset create/) &&
                  !line.match(/set -e/)
                expect(line).to match(/^rvm #{rvm_rubies} do/)
              end
            end
          end

          it 'runs rake without bundle exec' do
            described_class.rubies_shell_script
            expect(rvm_rubies.scan('@').count).to eq uniq_configs.count

            expect(output.last).to eq rakes.last

            yaml_configs.reverse.each_with_index do |config, i|
              index = -(i + 1)
              expect(output[index]).to eq rakes[index]
            end
          end
        end
      end

      context 'given rake is specified for some configs' do
        let(:yaml_configs) do
          ruby = "ruby_#{Faker::Lorem.word}"
          gemset = "gemset_#{Faker::Lorem.word}"
          rake = "rake_#{Faker::Lorem.word}"

          [
            yaml_config(ruby: "#{ruby}_1", gemset: "#{gemset}_1"),
            yaml_config(ruby: "#{ruby}_2", gemset: "#{gemset}_2", rake: rake),
          ]
        end

        before { expect(yaml_configs.any? { |c| c[:rake] }).to eq true }
        before { expect(yaml_configs.all? { |c| c[:rake] }).to eq false }

        it 'runs rake for each ruby according to the rake setting' do
          described_class.rubies_shell_script
          expect(rvm_rubies.scan('@').count).to eq yaml_configs.count

          expect(output.last).to eq rakes.last

          yaml_configs.reverse.each_with_index do |config, i|
            index = -(i + 1)
            expect(output[index]).to eq rakes[index]
          end
        end
      end
    end
  end
end

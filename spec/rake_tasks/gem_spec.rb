require_relative '../spec_helper'

describe RakeTasks::Gem do
  let(:klass) { RakeTasks::Gem }

  describe '::gem_spec_file' do
    let(:gemspecs) { Faker::Lorem.words }

    before { Util.stubs dir_glob: gemspecs }

    it 'returns a string' do
      assert_kind_of String, klass.gem_spec_file
    end

    context 'given a single gemspec' do
      let(:gemspecs) { [Faker::Lorem.words.first] }

      before { assert_equal 1, gemspecs.count }

      it 'returns the gemspec file name' do
        assert_equal gemspecs[0], klass.gem_spec_file
      end
    end

    context 'given multiple gemspecs' do
      let(:gemspecs) { Faker::Lorem.words }

      before { assert gemspecs.count > 1 }

      it 'returns the first gemspec file name' do
        assert_equal gemspecs[0], klass.gem_spec_file
      end
    end

    context 'given no gemspecs' do
      let(:gemspecs) { [] }
      before { assert_equal [], gemspecs }

      it 'returns nil' do
        assert_nil klass.gem_spec_file
      end
    end
  end

  describe '::version' do
    let(:new_version) { '%d.%d.%d' % [rand(98) + 1, rand(98) + 1, 2] }

    context 'given a gemspec file' do
      let(:gemspec_file) { "#{gem_name}.gemspec" }
      let(:gem_name) { Faker::Lorem.word }

      old_version = '%d.%d.%d' % [rand(98) + 1, rand(98) + 1, 1]
      let(:gemspec) { Gem::Specification.new(gem_name, old_version) }

      let(:gemspec_contents) {
        %Q{
Gem::Specification.new do |s|
  s.name = 'test_gem'
%s

  s.summary = 'Basic test gem.'
  s.description = <<DESC
This gem is a test gem.
It is used in tests.
DESC

  s.author   = 'Travis Herrick'
  s.email    = 'tthetoad@gmail.com'
  s.homepage = 'http://www.bitbucket.org/ToadJamb/gems_test_gem'

  s.license = 'LGPLv3'
end
        }.strip
      }

      before { refute_equal old_version, new_version }

      [
        "  version = '#{old_version}'",
        "  s.version = '#{old_version}'",
        "  s.version='#{old_version}'",
        "  s.version  =   '#{old_version}'",
        "  s.version  =   \"#{old_version}\"",
        "  s.version =\"#{old_version}\"",
      ].each do |version|
        context "given a version of '#{version}'" do
          let(:input) { StringIO.new(gemspec_contents % version) }
          let(:output) { StringIO.new(gemspec_contents % version) }

          before do
            Util.stubs(:dir_glob).with('*.gemspec').returns [gemspec_file]
            Util.stubs(:open_file).with(gemspec_file, 'r').yields input
            Util.stubs(:open_file).with(gemspec_file, 'w').yields output
            Gem::Specification.stubs(:load).with(gemspec_file).returns gemspec
          end

          it 'sets the version in the gemspec file' do
            klass.version! new_version

            output.rewind
            assert_match(/'#{new_version}'$/, output.read)
          end

          it 'accepts the gemspec as the second parameter' do
            klass.version! new_version, gemspec

            output.rewind
            assert_match(/'#{new_version}'$/, output.read)
          end
        end
      end
    end

    context 'given no gemspec' do
      before { Util.stubs(:dir_glob).with('*.gemspec').returns [] }
      before { assert_nil klass.gem_spec }
      it 'does nothing' do
        assert_nothing_raised { klass.version! new_version }
      end
    end
  end
end

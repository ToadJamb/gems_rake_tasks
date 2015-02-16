require 'spec_helper'

RSpec.describe RakeTasks::Gem do
  let(:klass) { RakeTasks::Gem }

  describe '::gem_spec_file' do
    let(:gemspecs) { Faker::Lorem.words }

    before { Util.stubs dir_glob: gemspecs }

    it 'returns a string' do
      expect(klass.gem_spec_file).to be_a String
    end

    context 'given a single gemspec' do
      let(:gemspecs) { [Faker::Lorem.words.first] }

      before { expect(gemspecs.count).to eq 1 }

      it 'returns the gemspec file name' do
        expect(klass.gem_spec_file).to eq gemspecs[0]
      end
    end

    context 'given multiple gemspecs' do
      let(:gemspecs) { Faker::Lorem.words }

      before { expect(gemspecs.count).to be > 1 }

      it 'returns the first gemspec file name' do
        expect(klass.gem_spec_file).to eq gemspecs[0]
      end
    end

    context 'given no gemspecs' do
      let(:gemspecs) { [] }
      before { expect(gemspecs).to eq [] }

      it 'returns nil' do
        expect(klass.gem_spec_file).to eq nil
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

      before { expect(new_version).to_not eq old_version }

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
            Util.stubs(:load_gemspec).with(gemspec_file).returns gemspec
          end

          it 'sets the version in the gemspec file' do
            klass.version! new_version

            output.rewind
            expect(output.read).to match(/'#{new_version}'$/)
          end

          it 'accepts the gemspec as the second parameter' do
            klass.version! new_version, gemspec

            output.rewind
            expect(output.read).to match(/'#{new_version}'$/)
          end
        end
      end
    end

    context 'given no gemspec' do
      before { Util.stubs(:dir_glob).with('*.gemspec').returns [] }
      before { expect(klass.gem_spec).to eq nil }
      it 'does nothing' do
        expect{ klass.version! new_version }.to_not raise_error
      end
    end
  end
end

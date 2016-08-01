require 'spec_helper'

RSpec.describe RakeTasks::Gem do
  let(:klass) { RakeTasks::Gem }

  describe '::gem_spec_file' do
    let(:gemspecs) { Faker::Lorem.words }

    before { mock_system(:dir_glob).and_return gemspecs }

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
            mock_system(:dir_glob).with('*.gemspec').and_return [gemspec_file]
            mock_system(:open_file).with(gemspec_file, 'r').and_yield input
            mock_system(:open_file).with(gemspec_file, 'w').and_yield output
            mock_system(:load_gemspec).with(gemspec_file).and_return gemspec
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
      before { mock_system(:dir_glob).with('*.gemspec').and_return [] }
      before { expect(klass.gem_spec).to eq nil }
      it 'does nothing' do
        expect{ klass.version! new_version }.to_not raise_error
      end
    end
  end

  describe '.push' do
    # This is here because the dependency is not expected
    # to be loaded by the library.
    # It is expected to be loaded by an application prior to loading rake tasks.
    require_quietly 'gems'

    subject { described_class.push }

    let(:gem_path) { 'path/to/gemspec' }
    let(:gem_file) { instance_double File }
    let(:api_key)  { 'rubygems-api-key' }

    before { stub_const 'ENV', {'RUBYGEMS_API_KEY' => api_key} }

    it 'pushes a gem' do
      allow(RakeTasks::Gem).to receive(:gem_file).and_return gem_path
      allow(File).to receive(:new).with(gem_path).and_return gem_file

      expect(Gems).to receive(:push).with gem_file
      expect(Gems.key).to_not eq api_key

      subject

      expect(Gems.key).to eq api_key
    end
  end

  describe '.next_version' do
    shared_examples_for 'next version' do |current, expected|
      subject { described_class }

      context "given the current version is #{current.inspect}" do
        before do
          allow(subject)
            .to receive(:version_number)
            .and_return current
        end

        it "returns #{expected.inspect}" do
          expect(subject.next_version).to eq expected
        end
      end
    end

    it_behaves_like 'next version', '4.1.0', '4.1.1'
    it_behaves_like 'next version', '4.1.3.5.8', '4.1.3.5.9'
    it_behaves_like 'next version', '4.1.2.wip', '4.1.3'
    it_behaves_like 'next version', '1.2.7.wip.3', '1.2.7.4'
  end
end

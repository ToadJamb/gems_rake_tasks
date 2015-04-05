require 'spec_helper'

RSpec.describe RakeTasks::Console do
  describe '.run' do
    subject { described_class.run }

    let(:command) { "bundle exec irb -Ilib -r#{lib}" }
    let(:lib)     { Faker::Lorem.word }

    before { described_class.instance_variable_set :@lib_folder, lib }

    it 'invokes the system command' do
      expect(RakeTasks::System)
        .to receive(:system)
        .with command
      subject
    end
  end

  describe '.lib_folder' do
    subject { described_class.lib_folder }

    let(:lib_name) { Faker::Lorem.word }

    let(:glob_results) {[
      'lib/foo_bar',
      "lib/#{lib_name}",
      'lib/fizz_buzz',
      "lib/#{lib_name}.rb",
    ]}

    before do
      described_class.instance_variable_set :@lib_folder, nil
      described_class.send :remove_instance_variable, :@lib_folder

      allow(RakeTasks::System)
        .to receive(:dir_glob)
        .with('lib/*')
        .and_return glob_results
    end

    context 'given folders in lib' do
      before do
        allow(RakeTasks::System).to receive(:directory?).and_return false
        allow(RakeTasks::System).to receive(:file?).and_return false

        glob_results.each do |glob_result|
          if File.extname(glob_result) == '.rb'
            allow(RakeTasks::System)
              .to receive(:file?)
              .with(glob_result)
              .and_return true
          else
            allow(RakeTasks::System)
              .to receive(:directory?)
              .with(glob_result)
              .and_return true
          end
        end
      end

      context 'given a file that matches a folder name' do
        it 'returns the folder name' do
          expect(subject).to eq lib_name
        end
      end

      context 'given no file matches a folder name' do
        let(:glob_results) {[
          'lib/foo_bar',
          "lib/#{lib_name}",
          'lib/fizz_buzz',
        ]}

        it('returns nil') { expect(subject).to eq nil }
      end
    end

    context 'given no folders in lib' do
      let(:glob_results) { [] }
      it('returns nil') { expect(subject).to eq nil }
    end
  end
end

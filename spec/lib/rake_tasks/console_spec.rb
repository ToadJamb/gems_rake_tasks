# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RakeTasks::Console do
  describe '.run' do
    subject { described_class.run }

    let(:command)  { "bundle exec irb -Ilib -r#{lib}" }
    let(:lib)      { "lib/#{Faker::Lorem.word}" }

    before { described_class.instance_variable_set :@lib_name, lib }

    it 'invokes the system command' do
      expect(RakeTasks::System)
        .to receive(:system)
        .with command
      subject
    end
  end

  describe '.lib_name' do
    shared_examples_for 'lib name' do |pwd, candidate, exists, expected|
      subject { described_class.lib_name }

      before do
        described_class.instance_variable_set :@lib_name, nil
        described_class.send :remove_instance_variable, :@lib_name
      end

      context "given the current path is: #{pwd.inspect}" do
        before do
          allow(RakeTasks::System)
            .to receive(:pwd)
            .and_return pwd

          allow(RakeTasks::System)
            .to receive(:file?)
            .with(candidate)
            .and_return exists
        end

        context "given the file does#{exists ? ' ' : ' not '}exist" do
          it "returns #{expected}" do
            expect(subject).to eq expected
          end
        end
      end
    end

    it_behaves_like 'lib name', 'path/foo', 'lib/foo.rb', true, 'foo'
    it_behaves_like 'lib name', 'path/foo', 'lib/foo.rb', false, nil
  end
end

require 'spec_helper'

RSpec.describe RakeTasks::Dependency do
  describe '.loaded?' do
    subject { described_class.loaded? constant.to_s, requirement }

    context 'given the constant exists' do
      let(:constant) { RakeTasks }
      let(:requirement) { 'rake_tasks' }

      it 'returns true' do
        expect(subject).to eq true
      end
    end

    context 'given the constant does not exist' do
      let(:constant) { 'FooBar' }
      let(:requirement) { 'foo_bar' }

      before { reset_io }

      it 'returns false' do
        expect(wrap_output{subject}).to eq false
      end

      it 'indicates that the constant is not defined' do
        wrap_output { subject }
        expect(out).to match(/#{constant}.*not defined/)
        expect(out).to match(/`require '#{requirement}'`/)
      end
    end
  end
end

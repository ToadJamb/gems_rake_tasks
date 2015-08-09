require 'spec_helper'

RSpec.describe RakeTasks::Dependency do
  describe '.loaded?' do
    subject { described_class.loaded? constant.to_s, requirement }

    shared_examples_for 'a loaded constant' do |const, req, exists|
      let(:constant)    { const }
      let(:requirement) { req }

      context "given #{const}" do
        if exists
          context 'exists' do
            it 'returns true' do
              expect(subject).to eq true
            end
          end
        else
          context 'does not exist', :stdout do
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
    end

    it_behaves_like 'a loaded constant', RakeTasks, 'rake_tasks', true
    it_behaves_like 'a loaded constant', 'FooBar', 'foo_bar', false
  end
end

# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RakeTasks::Dependency do
  let(:require_error_class) { LoadError }

  context "#{Kernel}.require" do
    it "raises a #{LoadError}" do
      expect{Kernel.require 'fizzbuzz'}.to raise_error require_error_class
    end
  end

  describe '.require_politely' do
    subject { described_class.require_politely lib, title, stream }

    let(:lib)    { 'my-lib' }
    let(:title)  { 'MyLib' }
    let(:error)  { nil }
    let(:stream) { StringIO.new }
    let(:out)    { stream.string }

    before do
      if error
        allow(Kernel).to receive(:require).with(lib).and_raise error
      else
        allow(Kernel).to receive(:require).with lib
      end
    end

    context 'given a valid library that can be loaded' do
      before { subject }

      it 'requires the file' do
        expect(Kernel).to have_received(:require).with lib
      end
    end

    context "given a #{LoadError}" do
      let(:error) { require_error_class.new 'lib not loaded' }

      before { subject }

      it 'outputs a message to the user' do
        expect(out).to match(/lib not loaded/)
        expect(out).to match(/could not be required/)
        expect(out).to match(/Please ensure that #{title}/)
      end
    end

    context "given an error other than #{LoadError}" do
      let(:error) { Exception.new 'wrong answer!' }
      it 'raises the error' do
        expect{subject}.to raise_error error
      end
    end
  end

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

    # The behavior on 1.9.3 is pickier than it is on 2.
    # Both of these cases resulted in failures on 1.9.3 with the original code.
    it_behaves_like 'a loaded constant', RakeTasks::Gem, 'rake_tasks/gem', true
    it_behaves_like 'a loaded constant', 'FooBar::Baz', 'foo_bar/baz', false
  end
end

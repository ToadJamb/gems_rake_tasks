require 'spec_helper'

RSpec.describe RakeTasks::System do
  shared_examples_for 'a delegated property' do |klass, method, delegate|
    let(:arg1) { 'abc' }
    let(:arg2) { 'def' }
    let(:arg3) { { :k1 => :v1 } }
    let(:arg4) { { :k2 => :v2 } }

    before do
      delegate ||= method
      described_class.unstub delegate
    end

    context 'given no arguments are passed' do
      it "calls #{klass}.#{method} with no arguments" do
        klass.expects(method).with
        described_class.send delegate
      end
    end

    context 'given 1 argument is passed' do
      it "calls #{klass}.#{method} with 1 argument" do
        klass.expects(method).with arg1
        described_class.send delegate, arg1
      end
    end

    context 'given 3 arguments are passed' do
      it "calls #{klass}.#{method} with 3 arguments" do
        klass.expects(method).with arg1, arg2, arg3
        described_class.send delegate, arg1, arg2, arg3
      end
    end

    context 'given multiple arguments are passed, followed by a hash' do
      it "calls #{klass}.#{method} with appropriate arguments" do
        klass.expects(method).with arg1, arg2, arg3, arg4
        described_class.send delegate, arg1, arg2, arg3, arg4
      end
    end
  end

  describe '.dir' do
    it_behaves_like 'a delegated property', Dir, :[], :dir
  end

  describe '.pwd' do
    it_behaves_like 'a delegated property', Dir, :pwd
  end

  describe '.import_task' do
    it_behaves_like 'a delegated property',
      RakeTasks::System, :import, :import_task
  end
end

require_relative '../../spec_helper'

describe Util do
  let(:klass) { Util }

  shared_examples_for 'a delegated property' do |klass, method, delegate|
    let(:test_class) { Util }
    let(:arg1) { Faker::Lorem.word }
    let(:arg2) { Faker::Lorem.word }
    let(:arg3) { { k1: :v1 } }
    let(:arg4) { { k2: :v2 } }

    before do
      delegate ||= method
      test_class.unstub delegate
    end

    context 'given no arguments are passed' do
      it "calls #{klass}.#{method} with no arguments" do
        klass.expects(method).with
        test_class.send delegate
      end
    end

    context 'given 1 argument is passed' do
      it "calls #{klass}.#{method} with 1 argument" do
        klass.expects(method).with arg1
        test_class.send delegate, arg1
      end
    end

    context 'given 3 arguments are passed' do
      it "calls #{klass}.#{method} with 3 arguments" do
        klass.expects(method).with arg1, arg2, arg3
        test_class.send delegate, arg1, arg2, arg3
      end
    end

    context 'given multiple arguments are passed, followed by a hash' do
      it "calls #{klass}.#{method} with appropriate arguments" do
        klass.expects(method).with arg1, arg2, arg3, arg4
        test_class.send delegate, arg1, arg2, arg3, arg4
      end
    end
  end

  describe '::dir_glob' do
    it_behaves_like 'a delegated property', Dir, :glob, :dir_glob
  end

  describe '::open_file' do
    let!(:arg1) { Faker::Lorem.word }
    let!(:arg2) { Faker::Lorem.word }

    it_behaves_like 'a delegated property', File, :open, :open_file

    it 'accepts a block and passes it to File.open' do
      klass.unstub :open_file
      File.expects(:open).with(arg1, arg2).yields

      block_called = false
      klass.open_file arg1, arg2 do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  describe '::file?' do
    it_behaves_like 'a delegated property', File, :file?
  end

  describe '::directory?' do
    it_behaves_like 'a delegated property', File, :directory?
  end

  describe '::rm' do
    it_behaves_like 'a delegated property', FileUtils, :rm
  end

  describe '::load_yaml' do
    it_behaves_like 'a delegated property', Psych, :load_file, :load_yaml
  end

  #describe '::home' do
  #  before do
  #    SaveUtil.unstub :home
  #    SaveUtil.unstub :expand_path
  #  end

  #  it 'calls File.expand_path with ~' do
  #    File.stubs(:expand_path).returns home.reverse
  #    File.expects(:expand_path).with('~').returns home

  #    expect(SaveUtil.home).to eq home
  #  end
  #end
end

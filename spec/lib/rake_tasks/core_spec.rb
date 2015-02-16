require 'spec_helper'

RSpec.describe RakeTasks::Core do
  subject do
    Module.new do
      extend RakeTasks::Core
    end
  end

  let(:path) { '/root/project' }
  let(:file_list) { [] }

  before { RakeTasks::System.stubs :pwd => path }

  it 'matches a glob that contains tasks folders with .rake files' do
    RakeTasks::System.unstub :dir
    RakeTasks::System
      .expects(:dir)
      .with("#{path}/**/tasks/**/*.rake")
      .returns []
    subject.load_tasks
  end

  context 'given files are returned' do
    let(:file_list) {[
      'file1.rake',
      'file2.rake',
    ]}

    before { expect(file_list.count).to be > 0 }
    before { RakeTasks::System.stubs :dir => file_list }

    it 'imports the files' do
      file_list.each do |file|
        RakeTasks::System
          .expects(:import_task)
          .with file
      end
      subject.load_tasks
    end
  end
end

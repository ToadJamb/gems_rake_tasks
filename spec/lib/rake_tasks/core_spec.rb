require 'spec_helper'

RSpec.describe RakeTasks::Core do
  subject do
    Module.new do
      extend RakeTasks::Core
    end
  end

  let(:path) { '/root/project' }
  let(:file_list) { [] }
  let(:lib_task_glob) { "#{path}/lib/tasks/**/*.rake" }
  let(:tasks_task_glob) { "#{path}/tasks/**/*.rake" }

  before { mock_system(:pwd).and_return path }

  it 'matches a glob that contains tasks folders with .rake files' do
    system_expects(:dir).with(lib_task_glob).and_return []
    system_expects(:dir).with(tasks_task_glob).and_return []

    subject.load_tasks
  end

  context 'given files are returned' do
    let(:lib_tasks) {[
      'lib_file1.rake',
      'lib_file2.rake',
      'lib_file3.rake',
    ]}

    let(:task_tasks) {[
      'task_file1.rake',
      'task_file2.rake',
    ]}

    before do
      mock_system(:dir).with(lib_task_glob).and_return lib_tasks
      mock_system(:dir).with(tasks_task_glob).and_return task_tasks

      expect(RakeTasks::System.dir(lib_task_glob).count).to be > 0
      expect(RakeTasks::System.dir(tasks_task_glob).count).to be > 0
    end

    it 'imports the files' do
      (lib_tasks + task_tasks).flatten.each do |file|
        system_expects(:import_task).with file
      end
      subject.load_tasks
    end
  end
end

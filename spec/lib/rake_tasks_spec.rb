require 'spec_helper'

RSpec.describe RakeTasks do
  let(:file_path) { File.expand_path 'lib/rake_tasks.rb' }

  def load_quietly(path)
    @verbose = $VERBOSE
    $VERBOSE = nil

    load path

    $VERBOSE = @verbose
  end

  it 'loads rake tasks' do
    described_class.expects :load_tasks
    load_quietly file_path
  end
end

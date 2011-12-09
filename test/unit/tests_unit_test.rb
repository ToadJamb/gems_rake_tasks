#--
################################################################################
#                      Copyright (C) 2011 Travis Herrick                       #
################################################################################
#                                                                              #
#                                 \v^V,^!v\^/                                  #
#                                 ~%       %~                                  #
#                                 {  _   _  }                                  #
#                                 (  *   -  )                                  #
#                                 |    /    |                                  #
#                                  \   _,  /                                   #
#                                   \__.__/                                    #
#                                                                              #
################################################################################
# This program is free software: you can redistribute it                       #
# and/or modify it under the terms of the GNU Lesser General Public License    #
# as published by the Free Software Foundation,                                #
# either version 3 of the License, or (at your option) any later version.      #
################################################################################
# This program is distributed in the hope that it will be useful,              #
# but WITHOUT ANY WARRANTY;                                                    #
# without even the implied warranty of MERCHANTABILITY                         #
# or FITNESS FOR A PARTICULAR PURPOSE.                                         #
# See the GNU Lesser General Public License for more details.                  #
#                                                                              #
# You should have received a copy of the GNU Lesser General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.        #
################################################################################
#++

require_relative File.join('../require'.split('/'))

class TestsUnitTest < Test::Unit::TestCase
  include RakeTasks::RakeTasksShared

  def setup
    super
    FakeFS.activate!
    FileUtils.mkdir_p root
    Dir.chdir root
    @module = RakeTasks
    @class  = @module::Tests
  end

  def teardown
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
    super
  end

  def test_file_name_to_task_name
    assert_equal 'something', @class.task_name('test/unit/something_test.rb')
    assert_equal 'something', @class.task_name('test/unit/test_something.rb')
  end

  def test_tests_exist
    paths.each do |path|
      files.each do |file|
        clear_test_files

        assert !@class.exist?, "#{path} folder should not contain anything."
        FileUtils.mkdir_p File.join(path, 'something')
        assert !@class.exist?,
          "#{path} folder should not contain any matching files."

        FileUtils.touch File.join(path, file.gsub(/\*/, 'abc'))
        assert @class.exist?, "#{path} should contain one matching file."
      end
    end
  end

  def test_file_list_and_types
    file_list = [
      { :path => 'alphabet', :file => 'abc' },
      { :path => 'alphabet', :file => 'def' },
      { :path => 'number'  , :file => 'add' },
    ]

    paths.each do |path|
      files.each do |file|
        clear_test_files
        list = file_list.map do |f|
          file_path = file.gsub(/\*/, f[:file])
          file_path = File.join(path, f[:path], file_path)

          FileUtils.mkdir_p File.dirname(file_path)
          FileUtils.touch file_path
          File.join root, file_path
        end

        FileUtils.mkdir_p File.join(root, path, 'color')
        FileUtils.touch File.join(root, path, 'color', 'red.txt')

        assert_equal list, @class.file_list
        assert_equal file_list.map { |f| f[:path] }.uniq, @class.types
      end
    end
  end

  def test_rubies_check
    paths.each do |path|
      clear_test_files
      FileUtils.mkdir_p path
      assert !@class.run_rubies?,
        'The user should not be able to run tests agaisnt multiple Rubies.'
      FileUtils.touch File.join(path, rubies_yaml_file)
      assert @class.run_rubies?,
        'The user should be able to run tests agaisnt multiple Rubies.'
    end
  end

  def test_config_data
    paths.each do |path|
      clear_test_files

      FileUtils.mkdir_p path

      configs.keys.each do |config|
        File.open("./#{path}/rubies.yml", 'w') do |file|
          file.write configs[config][:in]
        end

        assert_equal configs[config][:out], @class.test_configs,
          "rubies.yml in #{path} did not result in expected outcome"
      end
    end
  end

  def test_run_rubies
    path = paths[0]
    FileUtils.mkdir_p path

    configs.each do |k, v|
      next unless v[:out].is_a?(Array)

      File.open("./#{path}/rubies.yml", 'w') do |file|
        file.write v[:in]
      end

      matches = []
      gem_rubies = []
      v[:out].each_with_index do |config, i|
        if config[:ruby] and !config[:ruby].strip.empty?
          unless gem_rubies.include?(config[:ruby])
            gem_rubies << config[:ruby]
            gems = ['bash', @module::SCRIPTS[:gemsets]]

            Process.expects(:spawn).with(*gems, *config[:ruby].split('@'))
              .returns(101 + i).once
            Process.expects(:wait).with(101 + i).once
          end

          rubies = ['bash', @module::SCRIPTS[:rubies], 'test:all']
          rubies << config[:ruby]
          rubies << "_#{config[:rake]}_" if config[:rake]

          Process.expects(:spawn).with(*rubies,
            :out => 'out.log', :err => 'err.log').
            returns(71 + i).once
          Process.expects(:wait).with(71 + i).once

          matches << "#{config[:ruby]} - #{config[:rake]}\n*" if config[:rake]
        end
      end

      FileUtils.touch 'out.log'
      FileUtils.touch 'err.log'

      reset_io
      wrap_output { @class.run_ruby_tests }

      assert !File.file?('out.log'), 'Log file (out.log) should be deleted.'
      assert !File.file?('err.log'), 'Log file (err.log) should be deleted.'

      matches.each do |match|
        assert_match match, out
      end

      assert_no_match Regexp.new(" - \n"), out
    end
  end

  ############################################################################
  private
  ############################################################################

  def clear_test_files
    paths.each do |path|
      FileUtils.rm_rf(path) if File.directory?(path)
    end
  end

  def configs
    yaml = {
      :basic => {
        :out => [
          {:ruby => '1.9.2@my_gemset', :rake => '0.8.7'},
          {:ruby => '1.9.3@my_gems'  , :rake => '0.9.2'},
        ], # :out
      }, # :basic
      :no_rake => {
        :out => [
          {:ruby => '1.9.2@my_gemset'},
          {:ruby => '1.9.3@my_gems'  },
        ], # :out
      }, # :no_rake
      :ruby_only => {
        :out => [
          {:ruby => '1.9.2'},
          {:ruby => '1.9.3'},
        ], # :out
      }, # :ruby_only
      :gemset_only => {
        :out => [
          {:ruby => '@the_gem'},
          {:ruby => '@a_gem'},
        ], # :out
      }, # :gemset_only
      :multi_rake => {
        :out => [
          {:ruby => '1.9.3@multi_rake', :rake => '0.8.7'},
          {:ruby => '1.9.3@multi_rake', :rake => '0.9.2'},
        ], # :multi_rake
      }, # :basic
      :nothing => {
        :in  => '',
        :out => nil,
      }, # :nothing
      :nonsense => {
        :out => [],
      }, # :nonsense
    }

    yaml[:basic][:in] = <<-BASIC
- ruby: 1.9.2
  gemset: my_gemset
  rake: 0.8.7
- ruby: 1.9.3
  gemset: my_gems
  rake: 0.9.2
BASIC

    yaml[:no_rake][:in] = <<-NO_RAKE
- ruby: 1.9.2
  gemset: my_gemset
- ruby: 1.9.3
  gemset: my_gems
NO_RAKE

    yaml[:ruby_only][:in] = <<-RUBY_ONLY
- ruby: 1.9.2
- ruby: 1.9.3
RUBY_ONLY

    yaml[:gemset_only][:in] = <<-GEMSET_ONLY
- gemset: the_gem
- gemset: a_gem
GEMSET_ONLY

    yaml[:multi_rake][:in] = <<-MULTI_RAKE
- ruby: 1.9.3
  gemset: multi_rake
  rake: 0.8.7
- ruby: 1.9.3
  gemset: multi_rake
  rake: 0.9.2
MULTI_RAKE

    yaml[:nonsense][:in] = <<-NONSENSE
- key1: value1
- key2: value2
NONSENSE

    yaml.each_key do |k|
      yaml[k][:in] = yaml[k][:in].strip
    end

    yaml
  end

  def rubies_yaml_file
    'rubies.yml'
  end
end

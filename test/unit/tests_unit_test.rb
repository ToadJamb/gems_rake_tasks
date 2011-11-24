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
  def setup
    @class = RakeTasks::Tests
  end

  def test_file_name_to_task_name
    assert_equal 'something', @class.task_name('test/unit/something_test.rb')
    assert_equal 'something', @class.task_name('test/unit/test_something.rb')
  end

  def test_tests_exist
    @class.expects(:root => 'root').with.once
    Dir.expects(:[] => []).with('root/**').once
    assert_equal false, @class.exist?

    @class.expects(:root => 'root').with.once
    Dir.expects(:[] => ['root/path']).with('root/**').once
    assert @class.exist?
  end

  def test_file_list
    @class.stubs(:root => 'root').with
    @class.expects(:types => ['alphabet', 'number']).with.once

    patterns.each do |pattern|
      Dir.expects(
        :[] => []).with("root/#{pattern}").once
      case pattern
        when /^\*/
          Dir.expects(
            :[] => ['root/alphabet/abc_test.rb', 'root/alphabet/def_test.rb']).
            with("root/alphabet/#{pattern}").once
          Dir.expects(
            :[] => ['root/number/add_test.rb']).
            with("root/number/#{pattern}").once
        when /\*.rb$/
          Dir.expects(:[] => []).with("root/alphabet/#{pattern}").once
          Dir.expects(:[] => []).with("root/number/#{pattern}").once
      end
    end

    assert_equal [
      'root/alphabet/abc_test.rb',
      'root/alphabet/def_test.rb',
      'root/number/add_test.rb',
      ],
      @class.file_list
  end

  def test_types
    @class.stubs(:root => 'root')

    File.stubs(:directory? => true)
    File.expects(:directory? => false).with('root/file.rb').once

    Dir.expects(:[] => [
      'root/mammal', 'root/marsupial', 'root/primate', 'root/file.rb']).
      with('root/**').once

    patterns.each do |pattern|
      [
        "root/mammal/#{pattern}",
        "root/marsupial/#{pattern}",
        "root/primate/#{pattern}",
      ].each do |path|
        if path =~ /primate/
          Dir.expects(:[] => []).with(path).once
        else
          Dir.expects(:[] => [File.join(File.dirname(path), 'file_test.rb')]).
            with(path).at_least(0)
        end
      end
    end

    assert_equal ['mammal', 'marsupial'], @class.types
  end

  ############################################################################
  private
  ############################################################################

  # The patterns that indicate that a file contains tests.
  def patterns
    [
      '*_test.rb',
      'test_*.rb',
    ]
  end
end

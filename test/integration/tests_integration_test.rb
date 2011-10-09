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

class TestsIntegrationTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Tests
  end

  def test_root
    root = File.dirname(__FILE__)
    root = File.expand_path(File.join(root, '..'))
    root = File.basename(root)
    assert_equal root, @class.root
  end

  def test_tests_exist
    assert_equal true, @class.exist?
  end

  def test_types
    types = @class.types

    assert_equal 2, types.count

    ['integration', 'unit'].each do |type|
      assert types.include?(type), "Test types do not include #{type} tests."
    end
  end

  def test_file_list
    file = __FILE__[__FILE__.index(/\/#{@class.root}\//) + 1..-1]

    assert @class.file_list.include?(file),
      "#{file} is not in the list of test files:\n" +
      @class.file_list.join("\n")

    check_file_list :unit
    check_file_list :integration
  end

  ############################################################################
  private
  ############################################################################

  def check_file_list(group)
    files = Dir[File.join(@class.root, group.to_s, '*.rb')]

    assert_equal files.count, @class.file_list(group).count

    files.each do |file|
      assert @class.file_list(group).include?(file),
        "#{file} is not in the list of test files:\n" +
        @class.file_list(group).join("\n")
    end
  end
end

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

require_relative '../require'

class ParserTest < Test::Unit::TestCase
  include RakeTasks::RakeTasksShared

  def setup
    reset_io
    @module = RakeTasks
    @class  = @module::Parser
    @obj    = @class.new
  end

  def test_assert_works
    assert true
  end

  def test_lines_should_print
    printable_lines.each do |line|
      wrap_output { @obj.parse line }
      assert out.match(/#{line.chomp}\Z/)
    end
    assert_equal printable_lines.join(''), out
  end

  def test_lines_should_not_print
    unprintable_lines.each do |line|
      wrap_output { @obj.parse line }
      assert_no_match Regexp.new(line), out
    end
    assert_equal '', out
  end

  def test_summary
    summary_lines.each_value do |lines|
      check_lines lines
    end
  end

  def test_line_feeds_should_not_result_in_empty_lines
    lines = [
      "............\n",
      "\n",
      "35 tests, 203 assertions, 0 failures, 0 errors, 0 skips\n",
    ]

    lines.each do |line|
      wrap_output { @obj.parse line }
    end

    assert_equal lines[0] + lines[2].chomp, out
  end

  ##############################################################################
  private
  ##############################################################################

  def summary_lines
    {
      :single => {
        :in  => ["35 tests, 203 assertions, 0 failures, 0 errors, 0 skips\n"],
        :out => '35 tests, 203 assertions, 0 failures, 0 errors, 0 skips',
      },
      :mutiple => {
        :in  => ["35 tests, 194 assertions, 3 failures, 4 errors, 2 skips\n",
                 "35 tests, 196 assertions, 1 failures, 5 errors, 1 skips\n"],
        :out => '70 tests, 390 assertions, 4 failures, 9 errors, 3 skips',
      },
    }
  end

  def printable_lines
    [
      "Using /home/travis/.rvm/gems/ruby-1.9.3-p0 " +
        "with gemset rake_tasks_test\n",
      "...................................\n",
      "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE\n",
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF\n",
      "Finished in 0.208333 seconds.\n",
      "Finished tests in 0.246907s, 141.7536 tests/s, 822.1707 assertions/s.\n",
      "EF.EF.EF.EF.EF.EF.EF.EF.EF.EF.EF.EF\n",
      "35 tests, 203 assertions, 0 failures, 0 errors, 0 skips\n",
      "35 tests, 203 assertions, 0 failures, 0 errors, 0 skips",
    ]
  end

  def unprintable_lines
    [
      "Run options: \n",
      "# Running tests:\n",
      "\n",
    ]
  end

  def check_lines(lines)
    lines[:in].each do |line|
      wrap_output { @obj.parse line }
    end

    reset_io
    wrap_output { @obj.summarize }
    @obj = @class.new

    assert_equal lines[:out], out
  end
end

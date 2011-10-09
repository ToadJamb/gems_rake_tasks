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

class GemUnitTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Gem
  end

  def test_gem_spec_file
    Dir.expects(:getwd => '/root/path/gem_name').with.once

    assert_equal 'gem_name.gemspec', @class.gem_spec_file
  end

  def test_gem_file_existence
    Dir.expects(:getwd => '/root/path/gem_name').with.twice

    File.expects(:file?).
      returns(true, false).
      with('gem_name.gemspec').twice

    assert_equal true, @class.gem_file?
    assert_equal false, @class.gem_file?
  end
end

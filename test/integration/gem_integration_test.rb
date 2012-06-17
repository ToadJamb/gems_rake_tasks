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

require_relative File.join('../require.rb'.split('/'))

class GemIntegrationTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Gem
    @version = @class.gem_spec.version
  end

  def teardown
    if @version != @class.gem_spec.version
      @class.version! @version.to_s
    end
  end

  def test_gem_title
    assert_equal 'RakeTasks', @class.gem_title
  end

  def test_load_gem_spec
    assert_kind_of Gem::Specification, @class.gem_spec
  end

  def test_gem_spec_file
    assert_equal Dir['*.gemspec'].first, @class.gem_spec_file
  end

  def test_gem_file_exists
    assert @class.gem_file?, "#{@class.gem_spec_file} does not exist."
  end

  def test_set_version
    old_spec = @class.gem_spec
    @class.version! '0.0.0'
    new_spec = @class.gem_spec

    assert_not_equal old_spec.version, new_spec.version
    assert_equal '0.0.0', new_spec.version.to_s
  end

  def test_version
    spec = @class.gem_spec
    assert_equal "#{spec.name} version #{spec.version}", @class.version
  end
end

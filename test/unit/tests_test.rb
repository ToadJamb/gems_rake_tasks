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

require 'bundler'
require_relative File.join('../require'.split('/'))

class TestsUnitTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Tests
  end

  def test_class_name_to_task_name
    assert_equal 'something', @class.task_name('test/unit/something_test.rb')
    assert_equal 'something', @class.task_name('test/unit/test_something.rb')
  end


  #~ def test_tests_exist
    #~ assert_equal true, @class.exist?
  #~ end

  #~ def test_test_types
    #~ assert_equal ['unit', 'integration', 'functional'], @class.types
  #~ end

  #~ def test_real_gem_spec_file_exists
    #~ assert @class.gem_file?, 'This gem does not have a gem file.'
  #~ end

  #~ def test_gem_spec_file_exists
    #~ @class.stubs(:getwd => "/work/path/#{gem_spec.name}").once
    #~ @class.stubs(:file? => true).once
    #~ @class.expects(:gem_spec_file => @class.gem_spec_file).once
    #~ assert @class.gem_file?, 'Gem file should exist.'
  #~ end

  #~ def test_gem_spec_file_does_not_exist
    #~ @class.stubs(:getwd => "/work/path/#{gem_spec.name}").once
    #~ @class.stubs(:file? => false).once
    #~ assert !@class.gem_file?, 'Gem file should exist.'
  #~ end

  #~ def test_gem_spec_file_name
    #~ assert_equal "#{mock_path}/#{gem_spec.name}.gemspec", @class.gem_spec_file
  #~ end

  ############################################################################
  private
  ############################################################################

  def mock_path
    "/work/path/#{gem_spec.name}"
  end

  def gem_spec
    @gem_spec = mock.responds_like(Gem::Specification)
    @gem_spec.stubs(
      :name    => 'mock_gem',
      :version => '1.0.0'
    )
    @gem_spec
  end
end

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
    @spec_class = Gem::Specification
  end

  def test_gem_version_defaults
    spec = mock.responds_like(@spec_class.new)
    spec.expects(:name).with.returns('gem_name').once
    spec.expects(:version).with.returns('1.0.0').once

    @class.expects(:gem_spec).with.returns(spec).once

    assert_equal version('gem_name', '1.0.0'), @class.version
  end

  def test_gem_version
    spec = mock.responds_like(@spec_class.new)
    spec.expects(:name).with.returns('gem_name').once
    spec.expects(:version).with.returns('1.0.0').once
    assert_equal version('gem_name', '1.0.0'), @class.version(spec)
  end

  def test_gem_version_without_gemspec
    assert_equal nil, @class.version(nil)
  end

  def test_no_gem_spec
    simple_expectation(:getwd)
    File.expects(:file?).with(gem_name).returns(false).once

    spec = mock.responds_like(@spec_class)

    assert_nil @class.gem_spec(spec)
  end

  def test_gem_spec
    simple_expectation(:getwd)
    simple_expectation(:file?)

    spec = mock.responds_like(@spec_class)
    gem_spec = mock.responds_like(@spec_class.new)

    spec.expects(:load).with(gem_name).returns(gem_spec).once

    gem_spec.expects(:kind_of?).with(spec).returns(true)

    assert_kind_of spec, @class.gem_spec(spec)
  end

  def test_gem_spec_file
    simple_expectation(:getwd)
    File.expects(:file?).with(gem_name).returns(true, false).twice

    assert_equal gem_name, @class.gem_spec_file
    assert_equal nil, @class.gem_spec_file
  end

  def test_gem_file_existence
    simple_expectation(:getwd)

    File.expects(:file?).returns(true, false).with(gem_name).twice

    assert_equal true, @class.gem_file?
    assert_equal false, @class.gem_file?
  end

  ############################################################################
  private
  ############################################################################

  def simple_expectation(method)
    case method
      when :getwd then Dir.expects(:getwd => path).with.at_least_once
      when :file? then File.expects(:file? => true).with(gem_name).at_least_once
    end
  end

  def version(gem, version)
    '%s version %s' % [gem, version]
  end

  def gem_name
    File.basename(path) + '.gemspec'
  end

  def path
    '/root/path/gem_name'
  end
end

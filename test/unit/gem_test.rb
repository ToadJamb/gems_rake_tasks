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

class GemTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Gem
    @spec_class = Gem::Specification
  end

  test '.gem_spec_file returns the gemspec file name' do
    expect :gemspec_file
    assert_equal gem_spec_file_name, @class.gem_spec_file
  end

  test '.gem_spec_file returns the first gemspec' do
    expect :gemspec_file, ['b.gemspec', 'a.gemspec']
    assert_equal 'b.gemspec', @class.gem_spec_file
  end

  test '.gem_spec_file returns nil if the gemspec file does not exist' do
    expect :gemspec_file, []
    assert_nil @class.gem_spec_file
  end

  test '.gemspec_file? returns true if the gem spec exists' do
    expect :gemspec_file
    assert @class.gemspec_file?
  end

  test '.gemspec_file? returns false if the gem spec does not exist' do
    expect :gemspec_file, []
    assert !@class.gemspec_file?
  end

  test '.gem_spec expects to load a gem spec' do
    expect :gemspec_file
    @spec_class.expects(:load => true).with(gem_spec_file_name)
    assert @class.gem_spec
  end

  test '.gem_spec returns nil if there is not a gemspec file' do
    expect :gemspec_file, []
    @spec_class.expects(:load => true).never
    assert_nil @class.gem_spec
  end

  test '.gem_title returns the proper name of the gem' do
    mock_gem_spec :name => 'test_gem'
    assert_equal 'TestGem', @class.gem_title(@spec)
  end

  test '.gem_title returns nil if a valid gem spec is not passed in' do
    assert_nil @class.gem_title(nil)
    assert_nil @class.gem_title(Object.new)
  end

  test '.version returns the version of the gem' do
    mock_gem_spec :name => 'test_gem', :version => '0.0.1'
    assert_equal 'test_gem version 0.0.1', @class.version(@spec)
  end

  test '.version returns nil if a valid gem spec is not passed in' do
    assert_nil @class.version(nil)
    assert_nil @class.version(Object.new)

    spec = mock
    spec.stubs :name => 'test_gem'
    assert_nil @class.version(spec)

    spec = mock
    spec.stubs :version => '0.0.1'
    assert_nil @class.version(spec)
  end

  ############################################################################
  private
  ############################################################################

  def expect(method, result = nil)
    case method
    when :gemspec_file
      result ||= [gem_spec_file_name]
      Dir.expects(:glob => result).with('*.gemspec').at_least_once
    end
  end

  def gem_spec_file_name
    'test_gem.gemspec'
  end

  def mock_gem_spec(options = {})
    @spec = mock.responds_like(@spec_class.new)
    @spec.stubs options
  end

  def gem_spec(version)
    %Q{
Gem::Specification.new do |s|
  s.name = 'test_gem'
  s.version = '#{version}'

  s.summary = 'Basic test gem.'
  s.description = %Q{
This gem is a test gem.
It is used in tests.
}.strip

  s.author   = 'Travis Herrick'
  s.email    = 'tthetoad@gmail.com'
  s.homepage = 'http://www.bitbucket.org/ToadJamb/gems_test_gem'

  s.license = 'LGPLv3'
end
    }.strip
  end
end

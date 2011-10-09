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

  def test_set_version_error
    simple_expectation :getwd
    simple_expectation :file?
    simple_expectation :load_gem_spec
    simple_expectation :file_open

    temp_file = StringIO.new
    temp_file.expects(:close).with.at_least_once
    temp_file.expects(:unlink).with.at_least_once
    temp_file.expects(:flush).with.at_least_once
    temp_file.expects(:path => '/tmp/path/file_name').with

    Tempfile.expects(:new => temp_file)

    FileUtils.stubs(:mv).raises(Errno::ENOENT)

    assert_raises(Errno::ENOENT) { @class.version! '3.2.1' }
  end

  def test_set_version_in_different_formats
    simple_expectation :getwd
    simple_expectation :file?
    simple_expectation :load_gem_spec
    simple_expectation :mv

    [
      " = '0.0.1'",
      "='0.0.1'",
      "  =   '0.0.1'",
      '  =   "0.0.1"',
      ' ="0.0.1"',
    ].each do |version|
      temp = simple_expectation :new_tempfile
      new_spec = gem_spec_single_line(
        version.sub(/['"]\d\.\d\.\d['"]/, "'3.2.1'"))

      File.expects(:open => gem_spec_single_line(version)).
        with(gem_file, 'r').once

      @class.version! '3.2.1'

      assert_equal new_spec.string.strip, temp.string.strip
    end
  end

  def test_set_version
    simple_expectation :getwd
    simple_expectation :file?
    simple_expectation :load_gem_spec
    simple_expectation :mv

    temp_file = StringIO.new
    temp_file.expects(:path => '/tmp/path/file_name').with.once

    Tempfile.expects(:new => temp_file).once
    File.expects(:open => gem_spec).with(gem_file, 'r').once

    temp_file.expects(:close).with.once
    temp_file.expects(:unlink).with.once
    temp_file.expects(:flush).with.once

    @class.version! '3.2.1'
    assert_equal gem_spec('3.2.1').string.strip, temp_file.string.strip
  end

  def test_gem_version_defaults
    spec = mock.responds_like(@spec_class.new)
    spec.expects(:name).with.returns(gem_name).once
    spec.expects(:version).with.returns(gem_version).once

    @class.expects(:gem_spec).with.returns(spec).once

    assert_equal version(gem_name, gem_version), @class.version
  end

  def test_gem_version
    spec = mock.responds_like(@spec_class.new)
    spec.expects(:name).with.returns(gem_name).once
    spec.expects(:version).with.returns(gem_version).once
    assert_equal version(gem_name, gem_version), @class.version(spec)
  end

  def test_gem_version_without_gemspec
    assert_equal nil, @class.version(nil)
  end

  def test_no_gem_spec
    simple_expectation :getwd
    File.expects(:file?).with(gem_file).returns(false).once

    spec = mock.responds_like(@spec_class)

    assert_nil @class.gem_spec(spec)
  end

  def test_gem_spec
    simple_expectation :getwd
    simple_expectation :file?

    spec = mock.responds_like(@spec_class)
    gem_spec = mock.responds_like(@spec_class.new)

    spec.expects(:load).with(gem_file).returns(gem_spec).once

    gem_spec.expects(:kind_of?).with(spec).returns(true)

    assert_kind_of spec, @class.gem_spec(spec)
  end

  def test_gem_spec_file
    simple_expectation :getwd
    File.expects(:file?).with(gem_file).returns(true, false).twice

    assert_equal gem_file, @class.gem_spec_file
    assert_equal nil, @class.gem_spec_file
  end

  def test_gem_file_existence
    simple_expectation :getwd

    File.expects(:file?).returns(true, false).with(gem_file).twice

    assert_equal true, @class.gem_file?
    assert_equal false, @class.gem_file?
  end

  ############################################################################
  private
  ############################################################################

  def simple_expectation(method)
    case method
      when :getwd then Dir.expects(method => path).with.at_least_once
      when :file? then File.expects(method => true).with(gem_file).at_least_once
      when :load_gem_spec
        @spec_class.expects(:load => gem_spec_stub).with(gem_file).at_least_once
      when :mv then FileUtils.expects(:mv).at_least_once
      when :file_open
        File.expects(:open => gem_spec).with(gem_file, 'r').once
      when :new_tempfile
        temp_file = StringIO.new
        temp_file.expects(:close).with.at_least_once
        temp_file.expects(:unlink).with.at_least_once
        temp_file.expects(:flush).with.at_least_once
        temp_file.expects(:path => '/tmp/path/file_name').with
        Tempfile.expects(:new => temp_file)
        return temp_file
    end
  end

  def gem_spec_stub
    spec = mock.responds_like(@spec_class.new)
    spec.stubs(
      :name    => gem_name,
      :version => gem_version,
    )
    return spec
  end

  def gem_version
    '0.0.1'
  end

  def gem_name
    'test_gem'
  end

  def version(gem, version)
    '%s version %s' % [gem, version]
  end

  def gem_file
    File.basename(path) + '.gemspec'
  end

  def path
    '/root/path/' + gem_name
  end

  def gem_spec_single_line(version)
    StringIO.new %Q{
Gem::Specification.new do |s|
  s.name = 'test_gem'
  s.version#{version}
end
    }.strip

  end

  def gem_spec(version = gem_version)
    StringIO.new %Q{
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

  s.extra_rdoc_files << 'README'

  s.require_paths = ['lib']
  s.files = Dir['*', 'lib/**/*.rb', 'license/*']
  s.test_files = Dir['test/**/*.rb']

  s.add_dependency 'rdoc', '~> 3.9.4'
  s.add_dependency 'rake', '~> 0.9.2'

  s.add_development_dependency 'mocha', '~> 0.10.0'

  s.has_rdoc = true
end
    }.strip
  end
end

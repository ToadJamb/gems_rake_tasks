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

class DocUnitTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Doc
    @gem = RakeTasks::Gem
    @spec_class = Gem::Specification
    stubs :gem_spec
    stubs :file?
    @spec = @gem.gem_spec
    @obj = @class.new(@gem)
    @readme = nil
  end

  def test_readme_basic_contents
    [
      spec[:title],
      'Getting Started',
      'Usage',
      'Additional Notes',
      'Additional Documentation',
      "gem install #{spec[:name]}",
      "gem '#{spec[:name]}', '~> #{spec[:version]}'",
      "require '#{spec[:name]}'",
      "rake rdoc:app",
      "the #{spec[:license]} license",
    ].each do |text|
      assert_contains readme, text
    end
  end

  def test_no_license_information
    @spec.expects(:licenses).with.returns([]).at_least_once
    assert_not_contains readme, ' license.'
  end

  ############################################################################
  private
  ############################################################################

  def expectations(key)
    case key
      when :file_list then
        Dir.expects(:[]).returns(['license/file1', 'license/MiT'])
        Dir.expects(:[]).returns(['license/file1.jpg', 'license/MiT.png'])
    end
  end

  def stubs(item)
    case item
      when :file? then File.stubs(:file? => true)
      when :spec
        gem_spec = mock.responds_like(@spec_class.new)
        gem_spec.stubs spec
        return gem_spec
      when :gem_spec
        @gem.stubs(:gem_spec => stubs(:spec))
    end
  end

  def assert_not_contains(text, snippet)
    assert !text.include?(snippet),
      "The specified text should not contain '#{snippet}'."
  end

  def assert_contains(text, snippet)
    assert text.include?(snippet),
      "The specified text does not contain '#{snippet}'."
  end

  def readme
    @readme ||= @obj.readme_contents
  end

  def spec
    {
      :name        => 'test_gem',
      :title       => 'TestGem',
      :version     => '0.0.1',
      :licenses    => ['MIT', 'GPL'],
      :license     => 'MIT',
      :description =>
%Q{
A long explanation of what this thing can do.
Yeah, it's cool.
}.strip,
    }
  end
end

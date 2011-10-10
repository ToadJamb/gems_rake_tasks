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

class DocIntegrationTest < Test::Unit::TestCase
  def setup
    @class = RakeTasks::Doc
    @gem = RakeTasks::Gem
    @gem_spec = @gem.gem_spec
    @title = @gem.gem_title
    @obj = @class.new
  end

  def test_readme_basic_contents
    [
      @title,
      'Getting Started',
      'Usage',
      'Additional Notes',
      'Additional Documentation',
      "gem install #{@gem_spec.name}",
      "gem '#{@gem_spec.name}', '~> #{@gem_spec.version}'",
      "require '#{@gem_spec.name}'",
      "rake rdoc:app",
      "the {#{@gem_spec.license} license}" +
        "[link:../../license/#{@gem_spec.license.downcase}].\n\n" +
        "link:../../license/#{@gem_spec.license.downcase}.png",
    ].each do |text|
      assert_contains readme, text
    end
  end

  ############################################################################
  private
  ############################################################################

  def assert_contains(text, snippet)
    assert text.include?(snippet),
      "The specified text does not contain '#{snippet}'."
  end

  def readme
    @readme ||= @obj.readme_contents
  end
end

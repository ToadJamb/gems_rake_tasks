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

class TestsIntegrationTest < Test::Unit::TestCase
  # Supported ruby versions.
  def rubies
    [
      '1.9.2-p0',
      '1.9.2-p136',
      '1.9.2-p180',
      '1.9.2-p290',
      '1.9.2-p318',
      '1.9.2-p320',
      '1.9.3-p0',
      '1.9.3-p125',
      '1.9.3-p194',
    ]
  end
  private :rubies

  # Supported rake versions.
  def rakes
    ['0.8.7', '0.9.0', '0.9.1', '0.9.2', '0.9.2.2']
  end
  private :rakes

  def setup
    @module    = RakeTasks
    @class     = @module::Tests
    @file_path = 'test'
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
    file = File.join(@file_path, 'integration', File.basename(__FILE__))

    assert @class.file_list.include?(file),
      "#{file} is not in the list of test files:\n" +
      @class.file_list.join("\n")

    check_file_list :unit
    check_file_list :integration
  end

  def test_rubies
    assert_equal configs, @class.test_configs
  end

  def test_rubies_shell_script_location_should_be_lib
    loc = File.expand_path(File.join(
      File.dirname(__FILE__), '../../lib/rake_tasks/lib/rubies.sh'))
    assert_equal loc, @module::SCRIPTS[:rubies]
    assert File.file?(loc)
  end

  def test_bundle_install_shell_script_location_should_be_lib
    loc = File.expand_path(File.join(
      File.dirname(__FILE__), '../../lib/rake_tasks/lib/bundle_install.sh'))
    assert_equal loc, @module::SCRIPTS[:gemsets]
    assert File.file?(loc)
  end

  ############################################################################
  private
  ############################################################################

  def check_file_list(group)
    files = Dir[File.join(@file_path, group.to_s, '*.rb')]

    assert_equal files.count, @class.file_list(group).count

    files.each do |file|
      assert @class.file_list(group).include?(file),
        "#{file} is not in the list of test files:\n" +
        @class.file_list(group).join("\n")
    end
  end

  def configs
    configs = []
    rubies.each do |ruby|
      rakes.each do |rake|
        configs << { :ruby => ruby + '@rake_tasks_test', :rake => rake }
      end
    end
    return configs
  end
end

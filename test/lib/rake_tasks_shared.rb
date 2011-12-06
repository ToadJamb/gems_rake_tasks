# This file provides some common functions used in multiple test classes.

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

# Main module.
module RakeTasks
  # This module contains methods/info. that is shared among test classes.
  module RakeTasksShared

    ############################################################################
    private
    ############################################################################

    # The patterns that indicate that a file contains tests.
    def files
      ['*_test.rb',
        'test_*.rb']
    end

    # Paths that may contain tests.
    def paths
      ['test', 'tests']
    end

    # Returns the root folder.
    # This will always be '/root'.
    def root
      '/root'
    end

    ############################################################################
    # I/O support methods.
    ############################################################################

    # Returns the output from stdout as a string.
    # ==== Output
    # [String] The output from stdout.
    #
    #          All trailing line feeds are removed.
    def out
      @out.respond_to?(:string) ?  @out.string.gsub(/\n*\z/, '') : ''
    end

    # Returns the output from stderr as a string.
    # ==== Output
    # [String] The output from stderr.
    #
    #          All trailing line feeds are removed.
    def err
      @err.respond_to?(:string) ?  @err.string.gsub(/\n*\z/, '') : ''
    end

    # Return the actual output to stdout and stderr.
    # ==== Output
    # [Array] Two element array of strings.
    #
    #         The first element is from stdout.
    #
    #         The second element is from stderr.
    def real_finis
      return out, err
    end

    # Reset the stdout and stderr stream variables.
    def reset_io
      @out = StringIO.new
      @err = StringIO.new
    end

    # Wrap a block to capture the output to stdout and stderr.
    # ==== Input
    # [&block : Block] The block of code
    #                  that will have stdout and stderr trapped.
    def wrap_output(&block)
      begin
        $stdout = @out
        $stderr = @err
        yield
      rescue SystemExit
        AppState.state = :dead
      ensure
        $stdout = STDOUT
        $stderr = STDERR
      end
    end

    ############################################################################
    # Assertions.
    ############################################################################

    # Asserts that the specified text matches a given pattern.
    def assert_match(pattern, text, msg = nil)
      msg = msg || "<#{mu_pp(text)}> expected to match\n<#{mu_pp(pattern)}>"
      assert text.match(pattern), msg
    end
  end
end

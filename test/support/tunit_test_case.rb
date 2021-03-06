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

# Monkey patch Test::Unit::TestCase.
module Test::Unit
  class TestCase
    # Returns the name of the class that is being tested.
    # ==== Output
    # [String] The class that is being tested. nil if not found.
    def self.test_class
      return unless self.name.match(/^Test[A-Z]|Test$/)

      prefix_class = self.name.gsub!(/^Test([A-Z])/, '\\1')
      suffix_class = self.name.gsub!(/Test$/, '')

      case true
      when prefix_class && Kernel.const_defined?(prefix_class)
        prefix_class
      when suffix_class && Kernel.const_defined?(suffix_class)
        suffix_class
      end
    end
  end
end

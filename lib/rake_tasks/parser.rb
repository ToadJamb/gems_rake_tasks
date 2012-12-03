# This file holds the class that handles parsing output from files
# while testing across rubies/gemsets.

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

# The main module for this gem.
module RakeTasks
  # This class will handle parsing duties.
  class Parser
    def initialize
      @data = {
        tests:      0,
        assertions: 0,
        failures:   0,
        errors:     0,
        skips:      0,
      }
    end

    # Parse a given line.
    # It will be sent to standard out if it meets appropriate criteria.
    # Summary lines are split to provide sums of tests, assertions, etc.
    def parse(line)
      case line
        when /^[\.EF]+$/, /^Using /, /^Finished (tests )?in \d+/
          puts line.strip #unless line.strip.empty?
        when /^\d+ tests, \d+ assertions, /
          puts line.strip

          data = line.split(', ').map { |x| x.to_i }

          @data[:tests]      += data[0]
          @data[:assertions] += data[1]
          @data[:failures]   += data[2]
          @data[:errors]     += data[3]
          @data[:skips]      += data[4]
      end
    end

    # Calculate the summary and send it to standard out.
    def summarize
      puts "%d tests, %d assertions, %d failures, %d errors, %d skips" %
        @data.values
    end
  end
end

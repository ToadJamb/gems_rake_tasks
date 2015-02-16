require File.expand_path('spec/support/lib') # Must be first

require 'rspec'     # Must be before mocha/api
require 'mocha/api' # Must be after rspec

# Must be before spec/support
require File.expand_path('spec/support/require_quietly')

base = File.expand_path(File.dirname(__FILE__))
path = File.join(base, 'support')
Dir["#{path}/**/*.rb"].each do |file|
  require file
end

path = File.join(base, 'helpers')
Dir["#{path}/**/*.rb"].each do |file|
  require file
end

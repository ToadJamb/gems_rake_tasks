require 'test/unit'

require 'mocha/setup'

root = File.dirname(__FILE__)
Dir["#{root}/support/*.rb"].each do |file|
  require file
end

require_relative '../lib/rake_tasks'

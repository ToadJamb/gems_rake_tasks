require 'benchmark'

puts 'Keep individual measurements sub-second (app, specs, individual specs).'

benchmark_format = "%n\t#{Benchmark::FORMAT}"

puts Benchmark.measure('app') {
  require_relative '../lib/rake_tasks'
}.format(benchmark_format)

puts Benchmark.measure('specs') {
  require 'faker'
  require 'rspec'
  require 'mocha/api'

  base = File.expand_path(File.dirname(__FILE__))
  path = File.join(base, 'support')
  Dir["#{path}/**/*.rb"].each do |file|
    require file
  end

  path = File.join(base, 'helpers')
  Dir["#{path}/**/*.rb"].each do |file|
    require file
  end
}.format(benchmark_format)

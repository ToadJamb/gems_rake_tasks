require 'benchmark'

puts 'Keep individual measurements sub-second (app, specs, individual specs).'

if defined?(Benchmark::FORMAT)
  # Ruby 1.9.3
  benchmark_format = "%n\t#{Benchmark::FORMAT}"
elsif defined?(Benchmark::FMTSTR)
  # Ruby 1.9.2
  benchmark_format = "%n\t#{Benchmark::FMTSTR}"
end

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

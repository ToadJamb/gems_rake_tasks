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
  require File.expand_path('lib/rake_tasks')
}.format(benchmark_format)

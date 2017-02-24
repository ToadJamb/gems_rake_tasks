# frozen_string_literal: true
desc 'show a sample of all colors available in a 16 color console'
task :colors do
  RakeTasks::Dependency.require_politely 'colorize', 'Colorize'
  exit unless RakeTasks::Dependency.loaded?('Colorize', 'colorize')
  [
    :blue,
    :red,
    :green,
    :yellow,
    :magenta,
    :black,
    :white,
    :cyan,
    nil,
  ].each do |color|
    colors = [color]
    colors << "light_#{color}".to_sym if color

    colors.each do |clr|
      puts "This is a complete sentence in #{clr.inspect}.".colorize(clr)
    end
  end
end

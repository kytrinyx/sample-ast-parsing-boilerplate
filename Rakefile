desc "Analyze hellos"
task :analyze do
  require_relative "lib/sources"
  require_relative "lib/collectors/hello"
  require_relative "lib/items/hello"
  path = ENV["PATH"]

  hellos = Sources.walk(".", path: path, collector: Collectors::Hello).map(&:items).flatten
  hellos.each do |hello|
    puts hello
  end
end

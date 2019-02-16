require 'rubocop'
require 'parser/current'

module Sources
  def self.paths_at(location)
    if location.end_with?(".rb")
      [location]
    else
      Dir[File.join(location, "**", "*.rb")]
    end
  end

  def self.walk(root, path:, collector:)
    paths_at(File.join(root, path)).map do |path|
      process(File.read(path), path, collector: collector.new)
    end
  end

  def self.process(source, path, collector:)
    buffer        = Parser::Source::Buffer.new(path)
    buffer.source = source
    builder       = RuboCop::AST::Builder.new
    parser        = Parser::CurrentRuby.new(builder)
    root_node     = parser.parse(buffer)

    collector.process(root_node)

    # For debugging purposes, it's helpful to
    # know the filename that the source code was in,
    # So I typically add an `attr_accessor :source_file`
    # on any of the objects I create for the collectors
    # to return.
    collector.items.each do |item|
      item.source_file = path
    end
    collector
  end
end

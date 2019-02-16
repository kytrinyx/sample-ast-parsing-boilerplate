module Collectors
  class Hello < Parser::AST::Processor
    attr_reader :items

    # Look at https://github.com/whitequark/parser/blob/master/lib/parser/ast/processor.rb
    # for all the methods you can override.
    def on_class(node)
      if node.children.first.const_name == "HelloWorld"
        @items << analyze(node)
      end

      node.updated(nil, process_all(node))
    end

    def on_module(node)
      if node.children.first.const_name == "HelloWorld"
        @items << analyze(node)
      end

      node.updated(nil, process_all(node))
    end

    def initialize
      @items = []
    end

    private

    def analyze(node)
      item = Items::Hello.new(node.type)
      item.implemented_methods = extract_methods(node)

      hello_method = extract_hello_method(node)
      if hello_method
        item.arity = hello_method.arguments.count
      end

      item
    end

    # This is the pattern I use to extract a collection of similar things.
    def extract_methods(node)
      return [] if node.nil?

      if [:def, :defs].include?(node.type)
        return [node.method_name]
      end

      methods = []
      node.child_nodes.each do |child|
        methods += extract_methods(child)
      end
      methods
    end

    # This is the pattern I use to extract one target thing.
    def extract_hello_method(node)
      return nil if node.nil?

      if [:def, :defs].include?(node.type) && node.method_name == :hello
        return node
      end

      node.child_nodes.each do |child|
        result = extract_hello_method(child)
        return result if result
      end
      nil
    end
  end
end

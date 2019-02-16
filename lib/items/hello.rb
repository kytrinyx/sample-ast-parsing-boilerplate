module Items
  class Hello
    attr_accessor :source_file

    attr_accessor :implemented_methods, :arity
    attr_reader :implemented_as

    def initialize(implemented_as)
      @implemented_as = implemented_as
    end

    def to_s
      <<-HELLO

      --- #{source_file}
      implemented_as: #{implemented_as}
      methods: #{implemented_methods.join(", ")}
      arity of hello method: #{arity}
      HELLO
    end
  end
end

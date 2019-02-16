require_relative '../helper'
require_relative '../../lib/collectors/hello'
require_relative '../../lib/items/hello'

class HelloCollectorTest < Minitest::Test
  def test_a_class
    source = <<-SOURCE
      class HelloWorld
        def self.hello
          "Hello, World!"
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 1, items.count
    assert_equal :class, items.first.implemented_as
  end

  def test_a_module
    source = <<-SOURCE
      module HelloWorld
        def self.hello
          "Hello, World!"
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 1, items.count
    assert_equal :module, items.first.implemented_as
  end

  def test_wrong_name
    source = <<-SOURCE
      class GoodbyeWorld
        def self.goodbye
          "Goodbye, World!"
        end
      end

      module Whatever
        def self.yeah_yeah
          "Yeah, whatever!"
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 0, items.count
  end

  def test_too_complicated
    source = <<-SOURCE
      class HelloWorld
        def self.the_name(name)
          if name == ""
            return "World"
          else
            return name
          end
        end

        def self.construct_phrase(name)
          "Hello, \#{name}!"
        end

        def self.hello(name = "")
          construct_phrase(the_name(name))
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 1, items.count
    item = items.first

    assert_equal [:construct_phrase, :hello, :the_name], item.implemented_methods.sort
  end

  def test_with_instance
    source = <<-SOURCE
      class HelloWorld
        def self.hello(name = "World")
          new(name).to_s
        end

        attr_reader :name
        def initialize(name)
          @name = name
        end

        def to_s
          "Hello, \#{name}!"
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 1, items.count
    item = items.first

    assert_equal [:hello, :initialize, :to_s], item.implemented_methods.sort
  end

  def test_arity
    source = <<-SOURCE
      class HelloWorld
        def self.hello(name = "World")
          "Hello, \#{name}!"
        end
      end

      class HelloWorld
        def self.hello
          "Hello, World!"
        end
      end
    SOURCE
    items = Sources.process(source, "bogus_path.rb", collector: Collectors::Hello.new).items
    assert_equal 2, items.count
    hello1, hello2 = items

    assert_equal 1, hello1.arity
    assert_equal 0, hello2.arity
  end
end

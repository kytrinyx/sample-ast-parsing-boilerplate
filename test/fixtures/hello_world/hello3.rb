class HelloWorld
  def self.hello(name = "")
    if name == ""
      name = "World"
    end
    "Hello, #{name}!"
  end
end

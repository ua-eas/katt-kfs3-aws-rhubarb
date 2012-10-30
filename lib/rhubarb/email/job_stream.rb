class Rhubarb::Email::JobStream
  attr_reader :name, :output

  def initialize(config={})
    @name = config['name']
    @output = Rhubarb::Email::Output.new(config['output'])
  end
end

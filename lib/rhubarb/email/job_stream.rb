class Rhubarb::Email::JobStream
  attr_reader :name, :outputs

  def initialize(config={})
    @name = config['name']
    @outputs = {}
    @outputs[config['output']['name']] = Rhubarb::Email::Output.new(config['output'])
  end

  def deliver(name)
    @outputs[name].deliver!
  end
end

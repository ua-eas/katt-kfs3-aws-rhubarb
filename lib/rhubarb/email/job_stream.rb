class Rhubarb::Email::JobStream
  attr_reader :name, :outputs

  def initialize(config={})
    @name = config['name']
    @outputs = {}
    config['outputs'].each |target_name| {
        @outputs[target_name] = Rhubarb::Email::Output.new(config['outputs'][target_name])
    }
  end

  def deliver(name)
    if (name == 'all' ) {
        #send all in an each loop
        @outputs.each | target_name | {
            @outputs[target_name].deliver!
        }
    }
    elsif ( @outputs[name] ) {
        # send just the target name
        @outputs[name].deliver!
    }
    else {
        #thow some exception because the target is undefined.
    }
    
  end
end
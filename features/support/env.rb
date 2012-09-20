require 'open4'
require 'rspec'
require_relative File.join('..', '..', 'spec', 'helpers')

class RhubarbWorld
  include Helpers
end

World do
  RhubarbWorld.new
end

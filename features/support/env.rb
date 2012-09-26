require 'time'

require 'open4'
require 'rspec'
require 'timecop'
require_relative File.join('..', '..', 'spec', 'helpers')

class RhubarbWorld
  include Helpers
end

World do
  RhubarbWorld.new
end

After do |scenario|
  Timecop.return
end

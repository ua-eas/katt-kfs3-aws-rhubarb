require 'timecop'

require_relative '../lib/rhubarb'
require_relative 'helpers'


module Matchers
  class IncludeSomethingLike
    def initialize(expected_match)
      @expected_match = expected_match
    end

    def matches?(enumerable)
      @enumerable = enumerable
      @examples = @enumerable.select { |e| e =~ @expected_match }
      @examples.size > 0
    end

    def failure_message
      "expected #{@enumerable} to include something that matched /#{@expected_match}/, but no such luck"
    end

    def negative_failure_message
      "expected #{@enumerable} to not include anything that matched /#{@expected_match}/, but found '#{@examples.first}'"
    end
  end

  def include_something_like(expected)
    IncludeSomethingLike.new(expected)
  end
end

RSpec.configure do |config|
  config.include Matchers
end

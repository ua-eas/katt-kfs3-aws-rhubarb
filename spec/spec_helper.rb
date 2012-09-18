require 'timecop'

require_relative '../lib/rhubarb'

module Helpers
  def cleanse_live
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @canon_dir      = File.join(File.dirname(__FILE__), 'canon')
    @live_files     = File.join(@live_dir, '*')
    @canon_files    = File.join(@canon_dir, '*')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')
    @trn_batch_home = File.join(@live_dir, 'uaf-trn')

    # Delete everything in 'live'
    FileUtils.rm_rf Dir.glob(@live_files)

    # Copy from 'canon' to 'live'
    FileUtils.cp_r Dir.glob(@canon_files), @live_dir

    # For writable tests
    FileUtils.chmod 0500, File.join(@live_dir, 'uaf-trn', 'control')
  end
end

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

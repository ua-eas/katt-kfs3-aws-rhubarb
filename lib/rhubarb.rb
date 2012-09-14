require 'active_support/core_ext'
require 'log4r'

module Rhubarb
  class MissingBatchHomeError < StandardError
  end

  class InvalidBatchHomeError < StandardError
  end

  class EmptyBatchHomeError < StandardError
  end
end

require_relative 'rhubarb/batch_logger'

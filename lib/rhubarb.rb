require 'active_support/core_ext'
require 'log4r'

module Rhubarb
  # This method is purely to allow me to mock the instance method. I don't like
  # this but there it is.
  def self.batch_home
    ENV['BATCH_HOME']
  end

  def self.control_dir
    File.join(batch_home, 'control')
  end

  def self.validate_batch_home
    raise Rhubarb::MissingBatchHomeError if batch_home.nil?
    raise Rhubarb::InvalidBatchHomeError if not File.exist? batch_home
    batch_home_entries = Dir.new(batch_home).entries.reject {|e| e =~ /\.+|placeholder.txt/}
    raise Rhubarb::EmptyBatchHomeError if batch_home_entries.empty?
  end

  class EmptyBatchHomeError < StandardError
  end

  class InvalidBatchHomeError < StandardError
  end

  class MissingBatchHomeError < StandardError
  end

  class MissingControlDirectoryError < StandardError
  end

  class StatusFileTimeoutError < StandardError
  end

  class UnwritableControlDirectoryError < StandardError
  end
end

require_relative 'rhubarb/logger'
require_relative 'rhubarb/log_roller'
require_relative 'rhubarb/driver'

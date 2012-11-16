require 'mail'

# Rhubarb::Email manages Emails
class Rhubarb::Email
  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  def initialize()
    Rhubarb.validate_batch_home

    @logger = Rhubarb::Logger.new('email')
    debug "Rhubarb::Email initialized."
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  def self.parse_config(text)
    config_as_hash = YAML.load text
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # TODO raise if this file doesn't exist
  def self.parse_config_file(file_name)
    config_as_hash = YAML.load File.read(file_name)
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # TODO raise if this file doesn't exist
  def self.parse_addresses(file)
    @@addresses = YAML.load(File.read file)
  end

  # TODO raise if @@addresses doesn't exist
  def self.addresses
    @@addresses
  end
end

require_relative 'email/job_stream'
require_relative 'email/output'

# Internal: The main class which manages emailing reports for Rhubarb.

require 'mail'

class Rhubarb::Email
  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Public: Initialize an Email object
  def initialize()
    Rhubarb.validate_batch_home
    @logger = Rhubarb::Logger.new('email')

    parse_addresses

    debug "Rhubarb::Email initialized."
  end

  # Public: Gets batch home value from the Rhubarb object.
  #
  # Returns a string representing the batch home directory
  # def batch_home
  #   @batch_home ||= Rhubarb.batch_home
  # end

  # Public: Get the addresses hash
  #
  # hash of addresses
  def self.addresses
    # TODO raise if @@addresses doesn't exist
    @@addresses
  end

  def get_jobstream_by_name(job_stream)
    parse_config_file(job_stream)
  end

  def get_jobstream_from_text(config_text)
    parse_config(config_text)
  end
  
  private

  # Public: Parses the email yaml config based on a string passed in
  #           and instantiates a job stream object
  #
  # Returns a job stream object
  def parse_config(text)
    config_as_hash = YAML.load text
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # Interanl: Parses the email yaml config from a file and instantiates
  # a job stream object
  #
  # Returns a job stream object
  def parse_config_file(job_stream_name)
    # TODO raise if this file doesn't exist
    config_file = get_jobstream_config_file(job_stream_name)
    config_text = File.read(config_file)
    parse_config(config_text)
  end

  # Interanl: Parses addresses.yaml into a hash
  #
  # hash of addresses
  def parse_addresses

    # TODO raise if this file doesn't exist
    file_name = get_addresses_config_file
    @@addresses = YAML.load(File.read file_name)
  end

  def get_email_config_dir
    email_config_dir = ENV['RHUBARB_CONFIG'] ||= "./spec/test_config"
    email_config_dir += '/current/email/'
  end

  # Internal: Find the config file for addresses
  #
  #
  def get_addresses_config_file

    addresses_file = get_email_config_dir + '/addresses/'
    if ENV['RHUBARB_ENV']
      addresses_file = ENV['RHUBARB_ENV'] + '_'
    end
    addresses_file += 'addresses.yaml'
  end

  # Internal: Find the config file for addresses
  #
  #
  def get_jobstream_config_file(job_stream_name)

    config_file_name = get_email_config_dir + job_stream_name + '_email.yaml'
    config_file_name.downcase
  end

end

require_relative 'email/job_stream'
require_relative 'email/output'

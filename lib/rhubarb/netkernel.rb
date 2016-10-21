class Rhubarb::NetKernel
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils
  require 'net/http'
  require 'uri'

  attr_accessor :logger, :status_timeout, :status_sleep, :parsed_uri

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Rhubarb::NetKernel must be initialized with a pathname.
  # Examples: kfsjpmccardholder, kfsjpmctransaction
  #
  def initialize(uri)
    @parsed_uri = URI.parse(uri)
  end

  def notify
    response = Net::HTTP.get_response(@parsed_uri)
    response.body
  end

  def succeeded?(result)
    result.split("\n").each do |line|
      output_file = line.split(":")[1].strip
      if output_file.to_i.to_s == output_file
        return false
      end
    end
    return true
  end

end

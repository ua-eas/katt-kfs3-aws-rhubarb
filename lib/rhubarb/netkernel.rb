class Rhubarb::NetKernel
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils
  require 'net/http'
  require 'uri'

  attr_accessor :logger, :status_timeout, :status_sleep, :parsed_uri, :username, :password

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Rhubarb::NetKernel must be initialized with a pathname and credentials.
  # Examples: kfsjpmccardholder, kfsjpmctransaction
  #
  def initialize(uri, username, password)
    @parsed_uri = URI.parse(uri)
    @username = username
    @password = password
  end

  def notify
    req = Net::HTTP::Get.new(@parsed_uri)
    req.basic_auth @username, @password
    response = Net::HTTP.start(@parsed_uri.hostname, @parsed_uri.port) {|http|
      http.request(req)
    }
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

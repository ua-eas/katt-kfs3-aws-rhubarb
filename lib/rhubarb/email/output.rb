class Rhubarb::Email::Output
  attr_reader :name, :subject, :message, :to, :attachments_globs

  def initialize(config={})
    @name              = config['name']
    @subject           = config['subject']
    @message           = config['message']
    @to                = config['to']
    @attachments_globs = config['attachments_globs']
  end
end

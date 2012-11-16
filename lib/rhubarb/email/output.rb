class Rhubarb::Email::Output < Mail::Message
  attr_reader :name, :attachments_dir, :attachments_globs

  def initialize(config={})
    super()

    @name              = config['name']

    self['subject']    = config['subject']
    self['body']       = config['message']
    #self['from']       = '150.135.241.89@arizona.edu'
    self['from']       = Rhubarb::Email.addresses['FROM_ADDRESS']

    recipients         = []
    config['to'].each do |key|
      recipients << Rhubarb::Email.addresses[key]
    end
    self['to']         = recipients.join(',')

    @attachments_dir   = config['attachments_dir']
    @attachments_globs = config['attachments_globs']
    if @attachments_dir and @attachments_globs
      @attachments_globs.each do |glob|
        Dir.glob(File.join(@attachments_dir, glob)).each do |file|
          self.add_file file
        end
      end
    end
  end
end

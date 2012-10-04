# Rhubarb::SQL manages SQL execution against an Oracle database.
class Rhubarb::SQL
  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  def initialize(sql_script)
    Rhubarb.validate_batch_home

    @logger = Rhubarb::Logger.new('sql')
    debug "Rhubarb::SQL initialized with sql_script = '#{sql_script}'"

    if not File.directory? sql_dir
      error "'#{sql_dir}' directory does not exist, exiting."
      raise Rhubarb::SQL::MissingSQLDirectoryError
    end

    @sql_script = sql_script
  end

  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  # The "sql" directory, determined by `$BATCH_SQL`
  #
  # This method is purely to allow me to mock the instance method. I don't like
  # this but there it is.
  #
  # @return [String]
  def self.sql_dir
    File.join(Rhubarb.batch_home, 'sql')
  end

  def sql_dir
    Rhubarb::SQL.sql_dir
  end

  def run
  end

  # MissingSQLDirectoryError is raised when the SQL directory does not exist in
  # the filesystem.
  class MissingSQLDirectoryError < StandardError; end
end

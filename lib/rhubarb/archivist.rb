class Rhubarb::Archivist
  # Namespace for several file utility methods for copying, moving, removing, etc.
  include FileUtils

  attr_accessor :logger

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Rhubarb::Archive must be initialized with a subdirectory name, that is relative to `$BATCH\_HOME/staging/`.
  #
  # When initialized, Driver will first validate that {#batch\_home} is valid,
  # via {Rhubarb.validate\_batch\_home}. Also, a {Rhubarb::Logger} is
  # immediately created, accessible via {#logger}.
  def initialize(directory_name)
    Rhubarb.validate_batch_home

    @directory_name = directory_name
    @directory = File.join(batch_home, 'staging', @directory_name)
    @target    = File.join(batch_home, 'archive', @directory_name)

    @logger = Rhubarb::Logger.new('archivist')
    debug "Rhubarb::Archivist initialized with directory name = '#{@directory_name}'"

    if not File.directory? Rhubarb.control_dir
      error "'#{Rhubarb.control_dir}' directory does not exist, exiting."
      raise Rhubarb::MissingControlDirectoryError
    end
  end

  # Memoized getter for `@batch_home` (source is {Rhubarb.batch\_home})
  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  # Archive contents of directory. If `@directory` is
  # `purap/electronicInvoice/accept`, then this action will move all files in
  # `$BATCH\_HOME/staging/purap/electronicInvoice/accept` into
  # `$BATCH\_HOME/archive/purap/electronicInvoice/accept`. Two things to note:
  #
  # * If `@directory` does not exist in the filesystem (in the `staging`
  #   directory), a warning will be logged, but the method will succeed.
  # * If `@directory` does not exist in the `archive` directory, a warning will
  #   be logged, the directory will be created, the files will be moved, and the
  #   method will succeed.
  def archive!
    return if not source_exists?

    target_exists?
    @files = find_files

    info "archiving following files in `#{@directory_name}`:"
    info ''

    @time = Time.now.strftime("%Y%m%d%H%M%S")

    @files.each do |file|
      archive_file file
    end

    info ''
  end

  # archive a file from `@directory` into `@target`, changing the file name,
  # appending a timestamp to it.
  #
  # For example, at 2012-11-03 at 04:05:06, we would move `foo.xml` to
  #
  #     foo-20121103040506.xml
  def archive_file(file)
    info "* #{File.join(@directory, file)}"
    base = file.sub(File.extname(file), '')
    ext  = File.extname  file
    FileUtils.mv File.join(@directory, file), File.join(@target, "#{base}-#{@time}#{ext}")
  end

  def source_exists?
    return true if File.exist? @directory

    warn "Source directory (\"#{@directory}\") does not exist. Cannot proceed with archival."
    return false
  end

  def target_exists?
    return if File.exist? @target

    info "Target directory (\"#{@target}\") does not exist. Making it..."
    FileUtils.mkdir_p @target
  end

  # File names inside `@directory` that are not directories.
  def find_files
    Dir.
      glob(File.join(@directory, '*')).
      select { |e| not File.directory? e }.
      map { |e| File.basename(e) }
  end
end

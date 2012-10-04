When /^I run the command "(.*?)"$/ do |command|
  @pid, @stdin, @stdout, @stderr = Open4::popen4(command)
  ignored, @status = Process::waitpid2(@pid)
end

When /^I kick off the batch driver with "(.*?)" and "(.*?)"$/ do |job_stream_name, job_name|
  @job_stream_name = job_stream_name
  @job_name = job_name
  command = "bin/batch_drive #{job_stream_name} #{job_name}"
  @pid, @stdin, @stdout, @stderr = Open4::popen4(command)
  # Don't wait on it yet.
end

When /^the command returns$/ do
  ignored, @status = Process::waitpid2(@pid)
end

When /^I pretend to run the command "(.*?)"$/ do |command|
  #puts "ruby -e \"require 'timecop'; require 'time'; Timecop.travel(Time.parse('#{Time.now}')); Dir.chdir('bin'); eval(File.open('#{command}') {|h| h.read}); Dir.chdir('..')\""
  @pid, @stdin, @stdout, @stderr = Open4::popen4("ruby -e \"require 'timecop'; require 'time'; Timecop.travel(Time.parse('#{Time.now}')); Dir.chdir('bin'); eval(File.open('#{command}') {|h| h.read}); Dir.chdir('..')\"")
  ignored, @status = Process::waitpid2(@pid)
  #puts "STDOUT"
  #puts @stdout.read
  #puts "STDOUT"
  #puts "STDERR"
  #puts @stderr.read
  #puts "STDERR"
end

When /^I log something for "(.*?)"$/ do |job_stream|
  @pid, @stdin, @stdout, @stderr = Open4::popen4("bin/batch_log info #{job_stream}")
  ignored, @status = Process::waitpid2(@pid)
end

When /^the batch invoker removes the runfile$/ do
  sleep 2
  runfiles = Dir.glob(File.join(ENV['BATCH_HOME'], 'control', "#{@job_name}*.run"))
  raise "No runfiles in control directory!" if runfiles.empty?

  @runfile = runfiles[0]
  FileUtils.rm @runfile
  if @runfile =~ /(.+)\/(.+)\.run/
    @runfile_base = $2
  end
end

When /^the batch invoker drops a successful statusfile in the history directory$/ do
  sleep 1
  @statusfile = File.join(ENV['BATCH_HOME'], 'control', 'history', "#{@runfile_base}.status")
  File.write(@statusfile, "Aaand I Succeeded hooray!")
end

When /^the batch invoker drops a failed statusfile in the history directory$/ do
  sleep 1
  @statusfile = File.join(ENV['BATCH_HOME'], 'control', 'history', "#{@runfile_base}.status")
  File.write(@statusfile, "Aaand I Failed! Aww frown face.")
end

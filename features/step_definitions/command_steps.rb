When /^I run the command "(.*?)"$/ do |command|
  @pid, @stdin, @stdout, @stderr = Open4::popen4(command)
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

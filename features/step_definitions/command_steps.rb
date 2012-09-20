When /^I run the command "(.*?)"$/ do |command|
  @pid, @stdin, @stdout, @stderr = Open4::popen4(command)
  ignored, @status = Process::waitpid2(@pid)
end

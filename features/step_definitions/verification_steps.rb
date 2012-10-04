Then /^the command should return (successfully|unsuccessfully)$/ do |success|
  if success == 'successfully'
    @status.exitstatus.should be 0
  else
    @status.exitstatus.should_not be 0
  end
end

Then /^I should not see anything on (stdout|stderr)$/ do |pipe_name|
  pipe = ( pipe_name == 'stdout' ? @stdout : @stderr )
  lines = pipe.readlines
  lines.should be_empty
end

Then /^I should see "(.*?)" in "(.*?)"$/ do |text, file|
  lines = File.readlines(File.join(ENV['BATCH_HOME'], file))
  lines.last[text].should_not be nil
end

Then /^I should see \/(.*?)\/ in "(.*?)"$/ do |rgx, file|
  text = File.read(File.join(ENV['BATCH_HOME'], file))
  text.should match(Regexp.new rgx)
end

Then /^I should see \/(.*?)\/ in stdout$/ do |rgx|
    @stdout_text ||= @stdout.read
    @stdout_text.should match(Regexp.new rgx)
end

Then /^I should see no logs in the logs directory$/ do
  Dir.glob(File.join(ENV['BATCH_HOME'], 'logs', '*.log')).should be_empty
end

Then /^I should see a log in the "(.*?)" log archive directory$/ do |job_stream|
  File.directory?(File.join(ENV['BATCH_HOME'], 'logs', job_stream)).should be_true
  Dir.glob(File.join(ENV['BATCH_HOME'], 'logs', job_stream, '*.log')).should_not be_empty
end

Then /^I should see (\d+) logs in the "(.*?)" log archive directory$/ do |count, job_stream|
  count = count.to_i
  File.directory?(File.join(ENV['BATCH_HOME'], 'logs', job_stream)).should be_true
  Dir.glob(File.join(ENV['BATCH_HOME'], 'logs', job_stream, '*.log')).size.should be count
end

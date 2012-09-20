Then /^the command should return (successfully|unsuccessfully)$/ do |success|
  if success == 'successfully'
    @status.exitstatus.should be 0
  else
    @status.existstatus.should_not be 0
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

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

When /^BATCH_HOME is "(.*?)"$/ do |value|
  ENV['BATCH_HOME'] = File.expand_path(value)
end

Given /^the live directory is cleansed$/ do
  cleanse_live
end

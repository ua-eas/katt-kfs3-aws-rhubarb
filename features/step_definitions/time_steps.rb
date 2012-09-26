Given /^(?:now )?the time is "(.*?)" on "(.*?)"$/ do |time, date|
  t = Time.parse("#{date} #{time}")
  t_local = Time.local(t.year, t.month, t.day, t.hour, t.min, t.sec)
  Timecop.travel(t_local)
  puts Time.now
end

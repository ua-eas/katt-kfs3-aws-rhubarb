require_relative 'spec_helper'

describe Rhubarb::Email, "#parse_config" do
  before(:all) do
    Rhubarb::Email.parse_addresses(File.join(File.dirname(__FILE__), 'addresses.yaml'))

    js_archibus = <<ARCHIBUS
---
name: ARCHIBUS
output:
  name: report
  subject: "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
  message: >
    Attached are the reports that show the results and provide information on
    building/room records successfully updated and any error conditions found,
    if any, as a result of any Archibus files that were processed for the day.
  to:
  - KATT_AUTOMATION_ADDRESS
  - KFS_BSA_ADDRESS
  attachments_dir: "#{File.join(File.expand_path(File.dirname(__FILE__)), 'attachments')}"
  attachments_globs:
  - buildingImportErrorReport_*.txt
  - buildingImportSuccessReport_*.txt
  - roomImportErrorReport_*.txt
  - roomImportSuccessReport_*.txt
ARCHIBUS
    @js = Rhubarb::Email.parse_config(js_archibus)
  end

  it "should generate JobStream representing the whole job_stream, with a correct name" do
    @js.name.should == "ARCHIBUS"
  end

  it "should generate JobStream representing the whole job_stream, with a correct Output" do
    @js.outputs['report'].should_not be nil
  end

  it "should generate Output with a correct name" do
    @js.outputs['report'].name.should == "report"
  end

  it "should generate Output with a correct subject" do
    @js.outputs['report'].subject.should == "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
  end

  it "should generate Output with a correct message" do
    @js.outputs['report'].text_part.body.to_s.should == "Attached are the reports that show the results and provide information on building/room records successfully updated and any error conditions found, if any, as a result of any Archibus files that were processed for the day.\n"
  end

  it "should generate Output with correct to entries" do
    @js.outputs['report']['to'].to_s.should include("katt-automation@list.arizona.edu")
    @js.outputs['report']['to'].to_s.should include("kfsbsa@list.arizona.edu")
  end

  it "should generate an Output with correct attachments globs" do
    @js.outputs['report'].attachments_globs.should include("buildingImportErrorReport_*.txt")
    @js.outputs['report'].attachments_globs.should include("buildingImportSuccessReport_*.txt")
    @js.outputs['report'].attachments_globs.should include("roomImportErrorReport_*.txt")
    @js.outputs['report'].attachments_globs.should include("roomImportSuccessReport_*.txt")
  end

  it "should generate an Output with correct attached files" do
    @js.outputs['report'].attachments.map(&:filename).should include("buildingImportErrorReport_1.txt")
  end
end

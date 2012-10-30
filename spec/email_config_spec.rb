require_relative 'spec_helper'

describe Rhubarb::Email, "#parse_config" do
  before(:all) do
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
    @js.output.should_not be nil
  end

  it "should generate Output with a correct name" do
    @js.output.name.should == "report"
  end

  it "should generate Output with a correct subject" do
    @js.output.subject.should == "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
  end

  it "should generate Output with a correct message" do
    @js.output.message.should == "Attached are the reports that show the results and provide information on building/room records successfully updated and any error conditions found, if any, as a result of any Archibus files that were processed for the day.\n"
  end

  it "should generate Output with correct to entries" do
    @js.output.to.should include("KATT_AUTOMATION_ADDRESS")
    @js.output.to.should include("KFS_BSA_ADDRESS")
  end

  it "should generate an Output with correct attachments globs" do
    @js.output.attachments_globs.should include("buildingImportErrorReport_*.txt")
    @js.output.attachments_globs.should include("buildingImportSuccessReport_*.txt")
    @js.output.attachments_globs.should include("roomImportErrorReport_*.txt")
    @js.output.attachments_globs.should include("roomImportSuccessReport_*.txt")
  end
end

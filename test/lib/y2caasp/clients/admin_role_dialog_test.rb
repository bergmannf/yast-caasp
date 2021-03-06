#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"

require "y2caasp/clients/admin_role_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe ::Y2Caasp::AdminRoleDialog do
  describe "#run" do
    let(:ntp_servers) { [] }

    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
      allow(Yast::Lan).to receive(:ReadWithCacheNoGUI)
      allow(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return({})
      allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"

    # Note: this is a hypothetical test, in real CaaSP the default NTP setup
    # is currently disabled in control.xml
    context "no NTP server set in DHCP and default NTP is enabled in control.xml" do
      before do
        allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
          .with("globals", "default_ntp_setup").and_return(true)
        allow(Yast::Product).to receive(:FindBaseProducts)
          .and_return(["name" => "CAASP"])
      end

      it "proposes to use a random novell pool server" do
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new).and_wrap_original do |original, arg|
          expect(arg.first).to match(/\A[0-3]\.novell\.pool\.ntp\.org\z/)
          original.call(arg)
        end
        subject.run
      end
    end
  end
end

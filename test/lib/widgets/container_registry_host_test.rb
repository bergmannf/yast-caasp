#!/usr/bin/env rspec

require_relative "../../test_helper"
require "cwm/rspec"
require "y2caasp/widgets/container_registry_host"

describe Y2Caasp::Widgets::ContainerRegistryHost do
  subject(:widget) { Y2Caasp::Widgets::ContainerRegistryHost.new }
  let(:dashboard_role) { ::Installation::SystemRole.new(id: "dashboard_role", order: "100") }

  before do
    allow(::Installation::SystemRole).to receive(:current_role).and_return(dashboard_role)
  end

  include_examples "CWM::AbstractWidget"

  describe "#init" do
    subject(:widget) { Y2Caasp::Widgets::ContainerRegistryHost.new("default.registry.com") }

    it "reads initial value from dashboard role" do
      allow(dashboard_role).to receive(:[]).with("registry_host")
        .and_return("registry.suse.com")
      expect(widget).to receive(:value=).with("registry.suse.com")
      widget.init
    end

    context "when dashboard role does not define any server" do
      it "uses the default servers" do
        expect(widget).to receive(:value=).with("default.registry.com")
        widget.init
      end
    end
  end

  describe "#store" do
    let(:value) { "my.registry.com" }

    before do
      allow(widget).to receive(:value).and_return(value)
    end

    it "sets the role registry_host property" do
      widget.store
      expect(dashboard_role["registry_host"]).to eq(value)
    end
  end

  describe "#validate" do
    before do
      allow(widget).to receive(:value).and_return(value)
    end

    context "when valid IP addresses are provided" do
      let(:value) { "192.168.122.1" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when valid hostnames are provided" do
      let(:value) { "my.registry.de" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when non valid addresses/hostnames are provided" do
      let(:value) { "my.registry.*" }

      it "returns false" do
        allow(Yast::Popup).to receive(:Error)
        expect(widget.validate).to eq(false)
      end

      it "reports the problem to the user" do
        expect(Yast::Popup).to receive(:Error)
        widget.validate
      end
    end

    context "when no value is provided" do
      let(:value) { "" }

      it "returns false" do
        expect(widget.validate).to eq(false)
      end
    end
  end
end

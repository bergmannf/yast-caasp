#!/usr/bin/env rspec

require_relative "../../test_helper"
require "cwm/rspec"
require "y2caasp/widgets/container_registry_namespace"

describe Y2Caasp::Widgets::ContainerRegistryNamespace do
  subject(:widget) { Y2Caasp::Widgets::ContainerRegistryNamespace.new }
  let(:dashboard_role) { ::Installation::SystemRole.new(id: "dashboard_role", order: "100") }

  before do
    allow(::Installation::SystemRole).to receive(:current_role).and_return(dashboard_role)
  end

  include_examples "CWM::AbstractWidget"

  describe "#init" do
    subject(:widget) { Y2Caasp::Widgets::ContainerRegistryNamespace.new("a/namespace") }

    it "reads initial value from dashboard role" do
      allow(dashboard_role).to receive(:[]).with("registry_namespace")
        .and_return("other/namespace")
      expect(widget).to receive(:value=).with("other/namespace")
      widget.init
    end

    context "when dashboard role does not define any namespace" do
      it "uses the default namespace" do
        expect(widget).to receive(:value=).with("a/namespace")
        widget.init
      end
    end
  end

  describe "#store" do
    let(:value) { "my/namespace" }

    before do
      allow(widget).to receive(:value).and_return(value)
    end

    it "sets the role registry_namespace property" do
      widget.store
      expect(dashboard_role["registry_namespace"]).to eq(value)
    end
  end
end

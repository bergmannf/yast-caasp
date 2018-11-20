require "cfa/base_model"
require "cfa/augeas_parser"
require "cfa/matcher"

module Y2Caasp
  module CFA
    # Represents a Salt Minion master configuration file.
    class RegistryConf < ::CFA::BaseModel
      attributes(host: "registry.suse.com")
      attributes(namespace: "sles")

      # Configuration parser
      #
      # FIXME: At this time, we're using Augeas' cobblersettings lense because,
      # although the file is in yaml format, it doesn't have a YAML header
      # which is required by the yaml lense.
      PARSER = ::CFA::AugeasParser.new("cobblersettings.lns")
      # Path to configuration file
      # FIXME: These changes need to be mirrored to the workers later.
      PATH = "/usr/share/caasp-container-manifests/config/registry/registry-config.yaml".freeze

      # Constructor
      #
      # @param file_handler [.read, .write, nil] an object able to read/write a string.
      def initialize(file_handler: nil)
        super(PARSER, PATH, file_handler: file_handler)
      end

      def host=(host_name)
        data["host"] = host_name
      end

      def namespace=(registry_namespace)
        data["namespace"] = registry_namespace
      end
    end
  end
end

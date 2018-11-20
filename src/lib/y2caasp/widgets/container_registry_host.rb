# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2018 SUSE LLC
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact SUSE.
#
# To contact SUSE about this file by physical or electronic mail, you may find
# current contact information at www.suse.com.
# ------------------------------------------------------------------------------

require "yast"
require "cwm/widget"
require "installation/system_role"

module Y2Caasp
  module Widgets
    attr_reader :default_host

    class ContainerRegistryHost < CWM::InputField
      def initialize(default_host = "")
        @default_host = default_host
        textdomain "caasp"
      end

      def label
        _("Container registry host")
      end

      def help
        # TRANSLATORS: a help text for the controller node input field
        _("<h3>The Container Registry Host</h3>") +
          # TRANSLATORS: a help text for the controller node input field
          _("<p>Enter the host, that runs the registry." \
            "It must have all container-images required to run CaaS Platform available.</p>")
      end

      # It stores the value of the input field if validates
      #
      # @see #validate
      def store
        # this is a role widget so a role must be selected before saving
        raise("No role selected") unless role
        role["registry_host"] = value
      end

      # The input field is initialized with previous stored value
      def init
        if role && role["registry_host"]
          self.value = role["registry_host"]
        else
          self.value = @default_host
        end
      end

      # It returns true if the value is a valid IP or a valid FQDN, if not it
      # displays a popup error.
      #
      # @return [Boolean] true if valid IP or FQDN
      def validate
        return true if Yast::IP.Check(value) || Yast::Hostname.CheckFQ(value)

        Yast::Popup.Error(
          # TRANSLATORS: error message for invalid administration node location
          _("Not a valid location for the registry, please enter a valid IP or Hostname")
        )

        false
      end

    private

      # All other widgets have this
      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end

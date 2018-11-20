# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2017 SUSE LLC
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
require "cwm/dialog"
require "y2caasp/widgets/ntp_server"
require "y2caasp/widgets/container_registry_host"
require "y2caasp/widgets/container_registry_namespace"
require "y2caasp/dhcp_ntp_servers"

module Y2Caasp
  # This library provides a simple dialog for setting
  # the admin role specific settings:
  #   - the NTP server names
  class AdminRoleDialog < CWM::Dialog
    include DhcpNtpServers

    def initialize
      textdomain "caasp"

      Yast.import "Product"
      Yast.import "ProductFeatures"
      super
    end

    #
    # The dialog title
    #
    # @return [String] the title
    #
    def title
      # TRANSLATORS: dialog title
      _("Admin Node Configuration")
    end

    def contents
      return @content if @content

      @content = HSquash(
        MinWidth(50,
                 VBox(
                   # preselect the servers from the DHCP response
                   Y2Caasp::Widgets::NtpServer.new(ntp_servers),
                   VSpacing(2),
                   Y2Caasp::Widgets::ContainerRegistryHost.new("registry.suse.com"),
                   VSpacing(1),
                   Y2Caasp::Widgets::ContainerRegistryNamespace.new("sles"))))
    end

  private

    #
    # Propose the NTP servers from the DHCP response, fallback to a random
    # machine from the ntp.org pool if enabled in control.xml.
    #
    # @return [Array<String>] proposed NTP servers, empty if nothing suitable found
    #
    def ntp_servers
      # TODO: use Yast::NtpClient.ntp_conf if configured
      # to better handle going back
      servers = dhcp_ntp_servers
      servers = ntp_fallback if servers.empty?

      servers
    end

    #
    # The fallback servers for NTP configuration
    #
    # @return [Array<String>] the fallback servers, empty if disabled in control.xml
    #
    def ntp_fallback
      # propose the fallback when enabled in control file
      return [] unless Yast::ProductFeatures.GetBooleanFeature("globals", "default_ntp_setup")

      # copied from timezone/dialogs.rb:
      base_products = Yast::Product.FindBaseProducts
      host = if base_products.any? { |p| p["name"] =~ /openSUSE/i }
        "opensuse"
      else
        # TODO: use a SUSE server when available in the future
        "novell"
      end

      # propose a random pool server in range 0..3
      ["#{rand(4)}.#{host}.pool.ntp.org"]
    end
  end
end

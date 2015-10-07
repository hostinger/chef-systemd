#
# Cookbook Name:: systemd
# Library:: Systemd::Helpers
#
# Copyright 2015 The Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'mixlib/shellout'
require 'chef/resource'
require 'chef/recipe'

module Systemd

  # A set of helper methods and constants for in-cookbook
  # consumption. Not suitable for external use.
  module Helpers
    # list of supported systemd daemons
    DAEMONS ||= %i( journald logind resolved timesyncd )

    # list of supported systemd utilities
    UTILS ||= %i( bootchart coredump sleep system user )

    # unit types without custom options
    STUB_UNITS ||= %i( device target )

    # list of supported systemd units
    UNITS ||= %i(
      service socket device mount automount
      swap target path timer slice
    )

    # Returns an ini string given a config hash
    #
    # @param conf [Hash] a Hash object containing header(s) and options
    # @return [String] an ini-formatted string
    def ini_config(conf = {})
      conf.delete_if { |_, v| v.empty? }.map do |section, params|
        "[#{section.capitalize}]\n#{params.join("\n")}\n"
      end.join("\n")
    end

    def local_conf_root
      '/etc/systemd'
    end

    def unit_conf_root(conf)
      ::File.join(local_conf_root, conf.mode.to_s)
    end

    def conf_drop_in_root(conf)
      if conf.is_a?(Chef::Resource::SystemdUnit)
        ::File.join(
          unit_conf_root(conf),
          "#{conf.override}.#{conf.conf_type}.d"
        )
      else
        ::File.join(local_conf_root, "#{conf.conf_type}.conf.d")
      end
    end

    def conf_path(conf)
      if conf.drop_in
        ::File.join(conf_drop_in_root(conf), "#{conf.name}.conf")
      else
        if conf.is_a?(Chef::Resource::SystemdUnit)
          ::File.join(unit_conf_root(conf), "#{conf.name}.#{conf.conf_type}")
        else
          ::File.join(local_conf_root, "#{conf.conf_type}.conf")
        end
      end
    end

    module_function :ini_config, :local_conf_root, :unit_conf_root,
                    :conf_drop_in_root, :conf_path

    module Init
      def systemd?
        IO.read('/proc/1/comm').chomp == 'systemd'
      end
    end

    module RTC
      def rtc_mode?(lu)
        yn = lu == 'local' ? 'yes' : 'no'
        Mixlib::ShellOut.new('timedatectl')
          .tap(&:run_command)
          .stdout
          .match(Regexp.new("RTC in local TZ: #{yn}")) unless defined?(ChefSpec)
      end

      module_function :rtc_mode?
    end

    module Timezone
      def timezone?(tz)
        File.symlink?('/etc/localtime') &&
          File.readlink('/etc/localtime').match(Regexp.new("#{tz}$"))
      end

      module_function :timezone?
    end
  end
end

class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  def camelize
    gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
  end
end

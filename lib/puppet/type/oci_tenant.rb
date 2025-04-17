# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
require 'puppet_x/enterprisemodules/oci/core'

Puppet::Type.newtype(:oci_tenant) do
  include EasyType::YamlType

  config_file '/etc/oci_tenant.yaml'

  desc <<-DESC
  The tenant identifier.

  To get started with OCI in Puppet, you first have to identify the tenant you will use. See [this article](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/settinguptenancy.htm) on how you can set up a tenancy in OCI.

  Based on this information you can identify yourself to Puppet:

      oci_tenant {'tenant':
        tenancy_ocid => 'ocid1.tenancy.oc1..aaaaaaaaqf48mdndf7mmzgtbhyaqyyqlnjqj42ezgitogrfnz2a5qbw3mqa',
        user_ocid    => 'ocid1.user.oc1..aaaaaaaaw4yqam25cqygpst5e2eepr7nukpn2chf3ds6ftcypttw7tmkqyga',
        fingerprint  => '72:22:6d:f8:02:de:ee:6e:f5:a7:95:b9:72:f3:d8:eb',
        region       => 'eu-frankfurt-1',
        private_key  => "
      -----BEGIN RSA PRIVATE KEY-----
      ....

      MIIEpQIBAAKCAQEA4Qtpf303eu65bPKGXloBgfXTK4TwGzRdpHngxmWwZrEm/E3j
      ...
      -----END RSA PRIVATE KEY-----"
        }

  DESC

  parameter :name

  property :fingerprint
  property :private_key
  property :private_key_password
  property :region
  property :tenancy_ocid
  property :user_ocid
  property :proxy_address
  property :proxy_port
  property :proxy_user
  property :proxy_password
  property :instance_principal
  property :facts
  #
  # Properties to control OCI timeouts
  #
  property :base_sleep_time_millis
  property :sleep_calc_millis_proc
  property :max_attempts
  property :max_elapsed_time_millis
  property :max_sleep_between_attempts_millis
end

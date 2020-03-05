# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:license_model, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The Oracle license model that applies to the Oracle Autonomous Database. The default for Autonomous Database using the [shared deployment] is BRING_YOUR_OWN_LICENSE. Note that when provisioning an Autonomous Database using the [dedicated deployment](https://docs.cloud.oracle.com/Content/Database/Concepts/adbddoverview.htm) option, this attribute must be null because the attribute is already set on Autonomous Exadata Infrastructure level.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end

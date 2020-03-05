# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:type, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The type of backup to create. If omitted, defaults to INCREMENTAL.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end

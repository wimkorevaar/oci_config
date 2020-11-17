# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:time_created, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The date and time the snapshot was created, expressed
in [RFC 3339](https://tools.ietf.org/rfc/rfc3339) timestamp format.

Example: `2016-08-25T21:10:29.600Z`

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[Runtime]')
end

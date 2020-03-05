# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:storage_tier, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The type of storage tier of this bucket.
A bucket is set to 'Standard' tier by default, which means the bucket will be put in the standard storage tier.
When 'Archive' tier type is set explicitly, the bucket is put in the Archive Storage tier. The 'storageTier'
property is immutable after bucket is created.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end

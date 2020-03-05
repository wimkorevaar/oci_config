# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:vcn, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The Puppet name of the resource identified by `vcn_id`.

  See the documentation of vcn_id for all details.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  references :vcn_id
  reference_type :vcn
  data_type('Optional[String]')
end

child_of(:vcn, :vcn) { "#{tenant_string}/#{vcn}" }

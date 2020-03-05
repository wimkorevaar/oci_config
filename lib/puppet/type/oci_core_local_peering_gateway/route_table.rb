# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:route_table, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The Puppet name of the resource identified by `route_table_id`.

  See the documentation of route_table_id for all details.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  references :route_table_id
  reference_type :routetable
  data_type('Optional[String]')
end

child_of(:routetable, :route_table) { "#{tenant_string}/#{route_table}" }

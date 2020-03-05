# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:scope, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  Whether the public IP is regional or specific to a particular availability domain.

* `REGION`: The public IP exists within a region and is assigned to a regional entity
(such as a {NatGateway}), or can be assigned to a private
IP in any availability domain in the region. Reserved public IPs and ephemeral public IPs
assigned to a regional entity have `scope` = `REGION`.

* `AVAILABILITY_DOMAIN`: The public IP exists within the availability domain of the entity
it's assigned to, which is specified by the `availabilityDomain` property of the public IP object.
Ephemeral public IPs that are assigned to private IPs have `scope` = `AVAILABILITY_DOMAIN`.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end

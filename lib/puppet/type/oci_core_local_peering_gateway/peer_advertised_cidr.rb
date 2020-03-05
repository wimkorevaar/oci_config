# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:peer_advertised_cidr, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The smallest aggregate CIDR that contains all the CIDR routes advertised by the VCN
at the other end of the peering from this LPG. See `peerAdvertisedCidrDetails` for
the individual CIDRs. The value is `null` if the LPG is not peered.

Example: `192.168.0.0/16`, or if aggregated with `172.16.0.0/24` then `128.0.0.0/1`

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end

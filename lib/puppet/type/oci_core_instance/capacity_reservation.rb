# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:capacity_reservation, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  references :capacity_reservation_id
  reference_type :capacityreservation
  data_type('Optional[String]')
end

child_of(:capacityreservation, :capacity_reservation) { "#{tenant_string}/#{capacity_reservation}" }
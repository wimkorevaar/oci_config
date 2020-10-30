# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:kms_key, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  references :kms_key_id
  reference_type :key
  data_type('Optional[String]')
end

child_of(:key, :kms_key) { "#{tenant_string}/#{kms_key}" }
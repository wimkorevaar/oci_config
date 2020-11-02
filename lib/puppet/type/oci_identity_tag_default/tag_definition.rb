# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:tag_definition, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The Puppet name of the resource identified by `tag_definition_id`.

  See the documentation of tag_definition_id for all details.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  references :tag_definition_id
  reference_type :tagdefinition
  data_type('Optional[String]')
end

# child_of(:tagdefinition, :tag_definition) { "#{tenant_string}/#{tag_definition}" }
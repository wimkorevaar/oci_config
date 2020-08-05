# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
newproperty(:ncharacter_set, :parent => Puppet_X::EnterpriseModules::Oci::Property) do
  desc <<-DESC
  The national character set for the database.  The default is AL16UTF16. Allowed values are:
AL16UTF16 or UTF8.

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).
  DESC
  data_type('Optional[String]')
end
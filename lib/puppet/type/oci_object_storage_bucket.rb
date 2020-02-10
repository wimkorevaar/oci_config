# frozen_string_literal: true

#
# See the file "LICENSE" for the full license governing this code.
#
# This code is generated by the type generator. Modification will be overwritten
#
require 'puppet_x/enterprisemodules/oci/core'

Puppet::Type.newtype(:oci_object_storage_bucket) do
  include Puppet_X::EnterpriseModules::Oci::Type

  add_title_attributes(:bucket_name)

  ensurable

  parameter :name
  parameter :bucket_name
  parameter :tenant
  parameter :oci_timeout
  parameter :oci_wait_interval
  parameter :present_states
  parameter :absent_states
  parameter :synchronized
  parameter :compartment
  property  :id
  property  :compartment_id

  property :namespace
  property :metadata
  property :created_by
  property :time_created
  property :etag
  property :public_access_type
  property :storage_tier
  property :object_events_enabled
  property :freeform_tags
  property :defined_tags
  property :kms_key
  property :kms_key_id
  property :object_lifecycle_policy_etag
  property :approximate_count
  property :approximate_size

  validate do
    validate_reference_propery(:compartment_id, self)
    validate_reference_propery(:kms_key_id, self)
  end
end
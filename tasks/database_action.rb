#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

#
#
# See the file "LICENSE" for the full license governing this code.
#
#
$LOAD_PATH << "#{__dir__}/../lib"
$LOAD_PATH << "#{__dir__}/../../easy_type/lib"
require 'puppet_x/enterprisemodules/oci/oci_task'

# TODO: Docs
# docs
class DataabaseActionTask < Puppet_X::EnterpriseModules::Oci::PuppetTask
  parameter :db_node_name
  parameter :db_node_id
  parameter :action, 'START'
  oci_info  :db_node_name
  parameter :max_retries, 1
  client    OCI::Database::DatabaseClient

  def call_oci
    retries = 0
    ocid = if @db_node_name
             @resolver.name_to_ocid(@tenant, @db_node_name, :dbnode)
           else
             @db_node_id
           end
    begin
      @client.db_node_action(ocid, @action).data
    rescue OCI::Errors::ServiceError
      retries += 1
      retry if retries <= @max_retries
      raise
    end
  end
end

DataabaseActionTask.run if __FILE__ == $PROGRAM_NAME

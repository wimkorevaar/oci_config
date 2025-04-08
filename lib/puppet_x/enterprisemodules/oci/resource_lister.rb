# frozen_string_literal: true

module Puppet_X
  module EnterpriseModules
    module Oci
      # Docs
      class ResourceLister
        include Config
        include Settings
        def initialize(tenant, object_class)
          @tenant        = tenant
          @object_class  = object_class
          @object_type   = @object_class.to_s.split('::').last.underscore
          @resource_type = @object_class.to_s.gsub('::Models', '').split('::').join('_').underscore.to_sym
          @tenant_id     = settings_for(@tenant)['tenancy_ocid'] || Facter.value(:oci_instance)['compartment_id']
          @resolver      = Puppet_X::EnterpriseModules::Oci::NameResolver.instance(tenant)
        end

        def resource_list(compartment_id = nil)
          case ServiceInfo.type_to_lookup_method(@resource_type)
          when :root
            resources_at_root
          when :db_systems
            resources_in_db_systems(compartment_id)
          when :systems
            resources_in_systems(compartment_id)
          when :protocol
            resources_in_protocol(compartment_id)
          when :availability_domains
            resources_in_availability_domains(compartment_id)
          when :compartment
            resources_in_compartments(compartment_id)
          when :compartment_detailed
            resources_in_compartments(compartment_id, true)
          when :vault
            resources_in_vaults(compartment_id)
          when :drg
            resources_in_drgs(compartment_id)
          when :instance_pool
            resources_in_instance_pools(compartment_id)
          when :namespace
            resources_in_namespace(compartment_id)
          when :tag_namespace
            resources_in_tag_namespace
          else
            fail "Internal error: invalid primary_key for #{@resource_type}"
          end
        end

        private

        def handle_authorisation_errors(where)
          yield
        rescue OCI::Errors::ServiceError => e
          #
          # If we are not autorized, return an empty Hash and leave the property blank
          #
          raise unless e.service_code == 'NotAuthorizedOrNotFound'

          Puppet.debug "Skip fetching resources in #{where} because of an authorization failure."
          []
        end

        def resources_at_root
          Puppet.debug 'Inspecting root...'
          client.send("list_#{object_type_plural}").data
        end

        def compartment_list(specified_compartment)
          specified_compartment.nil? ? @resolver.compartments(@tenant).map(&:id) << @tenant_id : [specified_compartment]
        end

        def resources_in_compartments(specified_compartment, details_get = false)
          compartment_list(specified_compartment).collect do |compartment_id|
            handle_authorisation_errors(compartment_id) do
              Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
              case object_type_plural
              when 'pluggable_databases'
                client.list_pluggable_databases(:compartment_id => compartment_id).data
              when 'tag_defaults'
                client.list_tag_defaults(:compartment_id => compartment_id).data
              when 'exports'
                summary_data = client.list_exports(:compartment_id => compartment_id).data
                summary_data.collect do |export|
                  client.get_export(export.id).data
                end
              when 'public_ips'
                client.list_public_ips('REGION', compartment_id, :lifetime => 'RESERVED').data
              when 'network_security_groups'
                client.list_network_security_groups(:compartment_id => compartment_id).data
              # We are in a transaition periode between all calls to use positional parameters. That is
              # why there seem to be duplicate code for the volumes resource.
              when 'volumes'
                summary_data = client.send("list_#{object_type_plural}", :compartment_id => compartment_id).data
                Puppet.debug "Found #{summary_data.size} #{object_type_plural}..."
                if details_get
                  Puppet.debug "Fetching detailed data for #{object_type_plural}..."
                  summary_data.collect { |s| client.send("get_#{@object_type}", s.id).data }
                else
                  summary_data
                end
              else
                summary_data = client.send("list_#{object_type_plural}", compartment_id).data
                Puppet.debug "Found #{summary_data.size} #{object_type_plural}..."
                if details_get
                  Puppet.debug "Fetching detailed data for #{object_type_plural}..."
                  summary_data.collect { |s| client.send("get_#{@object_type}", s.id).data }
                else
                  summary_data
                end
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_protocol(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            handle_authorisation_errors(compartment_id) do
              Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
              Puppet.debug 'Inspecting protocol SAML2...'
              client.send("list_#{object_type_plural}", 'SAML2', compartment_id).data
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_db_systems(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            db_systems_in(compartment_id).collect do |db_system_id|
              handle_authorisation_errors(compartment_id) do
                Puppet.debug "Inspecting database #{db_system_id}..."
                client.send("list_#{object_type_plural}", compartment_id, :db_system_id => db_system_id).data
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_systems(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            db_systems_in(compartment_id).collect do |system_id|
              handle_authorisation_errors(compartment_id) do
                Puppet.debug "Inspecting database #{system_id}..."
                client.send("list_#{object_type_plural}", compartment_id, :system_id => system_id).data
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_namespace(specified_compartment)
          namespace = client.get_namespace.data
          compartment_list(specified_compartment).collect do |compartment_id|
            handle_authorisation_errors(compartment_id) do
              Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
              buckets = client.list_buckets(namespace, compartment_id).data
              buckets.collect { |b| client.get_bucket(namespace, b.name).data }
            end
          end.flatten.compact.uniq(&:name)
        end

        def resources_in_tag_namespace
          compartment_list(nil).collect do |compartment_id|
            handle_authorisation_errors(compartment_id) do
              Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
              tag_namespaces_in(compartment_id).collect do |tag_namespace_id|
                handle_authorisation_errors(compartment_id) do
                  Puppet.debug "Inspecting tag namespace #{tag_namespace_id}..."
                  summary_data = client.list_tags(tag_namespace_id).data
                  summary_data.collect { |s| client.get_tag(tag_namespace_id, s.name).data }
                end
              end
            end
          end.flatten.compact
        end

        def resources_in_vaults(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            vaults_in(compartment_id).collect do |vault|
              handle_authorisation_errors(compartment_id) do
                kms_management_client = client_for(OCI::KeyManagement::KmsManagementClient, @tenant, :endpoint => vault.management_endpoint)
                Puppet.debug "Inspecting vault #{vault.id}..."
                kms_management_client.send("list_#{object_type_plural}", compartment_id).data
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_drgs(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            drgs_in(compartment_id).collect do |drg_id|
              handle_authorisation_errors(compartment_id) do
                Puppet.debug "Inspecting drg #{drg_id}..."
                client.send("list_#{object_type_plural}", drg_id).data
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_instance_pools(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            instance_pools_in(compartment_id).collect do |instance_pool_id|
              handle_authorisation_errors(compartment_id) do
                Puppet.debug "Inspecting instance_pool #{instance_pool_id}..."
                client.send("list_#{object_type_plural}", compartment_id, instance_pool_id).data
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def resources_in_availability_domains(specified_compartment)
          compartment_list(specified_compartment).collect do |compartment_id|
            Puppet.debug "Inspecting compartment #{@resolver.ocid_to_full_name(@tenant, compartment_id)} for #{object_type_plural}..."
            availability_domains_in(compartment_id).collect do |availability_domain|
              handle_authorisation_errors(compartment_id) do
                Puppet.debug "Inspecting availability domain #{availability_domain} for #{object_type_plural}..."
                case @object_type
                when 'file_system', 'mount_target'
                  client.send("list_#{object_type_plural}", compartment_id, availability_domain).data
                when 'snapshot'
                  file_systems = client.list_file_systems(compartment_id, availability_domain).data
                  file_systems.collect { |fs| client.list_snapshots(fs.id).data }
                else
                  client.send("list_#{object_type_plural}", :availability_domain => availability_domain, :compartment_id => compartment_id).data
                end
              end
            end
          end.flatten.compact.uniq(&:id)
        end

        def db_systems_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            db_client = client_for(OCI::Database::DatabaseClient, @tenant)
            db_client.send('list_db_systems', compartment_id).data.collect(&:id)
          end
        end

        def vncs_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            vcn_client = client_for(OCI::Core::VirtualNetworkClient, @tenant)
            vcn_client.send('list_vcns', compartment_id).data.collect(&:id)
          end
        end

        def tag_namespaces_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            identity_client = client_for(OCI::Identity::IdentityClient, @tenant)
            identity_client.list_tag_namespaces(compartment_id).data.collect(&:id)
          end
        end

        def vaults_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            vault_client = client_for(OCI::KeyManagement::KmsVaultClient, @tenant)
            vault_client.send('list_vaults', compartment_id).data.reject { |e| e.lifecycle_state =~ /DELETE/ }
          end
        end

        def drgs_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            drg_client = client_for(OCI::Core::VirtualNetworkClient, @tenant)
            drg_client.send('list_drgs', compartment_id).data.collect(&:id)
          end
        end

        def instance_pools_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            drg_client = client_for(OCI::Core::ComputeManagementClient, @tenant)
            drg_client.send('list_instance_pools', compartment_id).data.collect(&:id)
          end
        end

        def availability_domains_in(compartment_id)
          handle_authorisation_errors(compartment_id) do
            identity_client = client_for(OCI::Identity::IdentityClient, @tenant)
            identity_client.send('list_availability_domains', compartment_id).data.collect(&:name)
          end
        end

        def client
          @client ||= client_for(ServiceInfo.type_to_client(@resource_type), @tenant)
        end

        def object_type_plural
          if @object_type[-1] == 's'
            @object_type
          elsif @object_type[-2..-1] == 'cy'
            "#{@object_type[0...-1]}ies"
          else
            "#{@object_type}s"
          end
        end
      end
    end
  end
end

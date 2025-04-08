# frozen_string_literal: true

module Puppet_X
  module EnterpriseModules
    module Oci
      # Add Documentation
      module Type
        def self.included(parent)
          parent.send(:include, EasyType)
          parent.send(:include, Settings)
          parent.send(:include, Config)
          parent.extend(Config)
          parent.extend(ClassMethods)
          parent.extend(Settings)
        end

        # rubocop: disable Lint/OrAssignmentToConstant
        MULTI_ELEMENT_PROVIDERS ||= [
          'Puppet::Type::Oci_file_storage_snapshot::ProviderSdk',
          'Puppet::Type::Oci_identity_tag::ProviderSdk',
          'Puppet::Type::Oci_identity_tag_default::ProviderSdk'
        ].freeze

        PUPPET_META_ATTRIBUTES ||= [:name,
                                    :alias,
                                    :audit,
                                    :before,
                                    :loglevel,
                                    :noop,
                                    :notify,
                                    :require,
                                    :schedule,
                                    :stage,
                                    :subscribe,
                                    :tag,
                                    :provider].freeze
        # rubocop: enable Lint/OrAssignmentToConstant

        def oci_api_data
          @oci_api_data
        end

        def validate_reference_propery(property, resource)
          reference_property = property.to_s.scan(/(.*)_id(s)?$/).first.join
          fail "You cannot use both #{property} and #{reference_property} together. Choose either one." \
            if resource.send(reference_property.to_sym) && resource.send(property.to_sym)
        end

        def before_create
          @oci_api_data = to_hash
          #
          # In Puppet the name is the full name. OCI needs just the name.
          # Also sometimes OCI doesn't have a name but just a display_name. So we
          # fill this in too.
          #
          @oci_api_data[:name] = bare_name
          @oci_api_data[:display_name] = bare_name
          #
          # If the compartment_id is nil, it means we are at the root and use the tenant ocid
          #
          @oci_api_data[:compartment_id] ||= client.api_client.config.tenancy
        end

        def on_create
          Puppet.debug "create #{object_type} #{name} "
          #
          # In Puppet we use underscored names, but OCI needs camel case with a lowecase
          # first character.
          #
          @oci_api_data = @oci_api_data.to_oci
          handle_oci_request do
            @oci_api_data = case object_type
                            when 'tag'
                              tag_namespace_id = resolver.name_to_ocid(tenant, tag_namespace_name, :tagnamespace)
                              create_details = create_class.new(@oci_api_data)
                              client.create_tag(tag_namespace_id, create_details)
                            when 'instance'
                              launch_details = launch_class.new(@oci_api_data)
                              creation_data = client.launch_instance(launch_details)
                              #
                              # The creation of an instance also create's a boot image. To allow searching for it
                              # in the cache, invalidate the cache of boot volumes. This is not very efficient. Specialy
                              # in large environments.
                              # TODO: Find a way to make this more effecient
                              #
                              resolver.invalidate(tenant, :bootvolume)
                              creation_data
                            when 'bucket'
                              namespace = client.get_namespace.data
                              create_details = create_class.new(@oci_api_data)
                              client.send("create_#{object_type}", namespace, create_details)
                            when 'vcn'
                              #
                              # Version 2.18 of the sdk always sets the is_oracle_gua_allocation_enabled property. This causes the
                              # API to fail that why we set it to nil when it isn't explicitly set to true
                              #
                              create_details = create_class.new(@oci_api_data)
                              create_details.is_oracle_gua_allocation_enabled = nil unless is_oracle_gua_allocation_enabled.to_s == 'true'
                              client.send("create_#{object_type}", create_details)
                            else
                              create_details = create_class.new(@oci_api_data)
                              client.send("create_#{object_type}", create_details)
                            end
          end
          #
          # Add the created resource to the name cache so new Puppet resources can find it
          #
          resolver.add_to_cache(tenant, @oci_api_data.data)
          #
          # Report the information back to the provide
          #
          hash = @oci_api_data.data.to_hash.to_puppet
          hash['tenant'] = tenant
          hash['name'] = name
          self[:provider] = self.class.defaultprovider.map_raw_to_resource(hash)
        end

        def before_modify
          @oci_api_data = to_hash
          #
          # Although OCI allows renaming, Puppet doesn't, so we delete the name and display_name
          # attributes
          #
          @oci_api_data.delete(:name)
          @oci_api_data.delete(:display_name)
        end

        def on_modify
          Puppet.debug "modify #{object_type} #{name}"
          #
          # In Puppet we use underscored names, but OCI needs camel case with a lowecase
          # first character.
          #
          @oci_api_data = @oci_api_data.to_oci
          update_details = update_class.new(@oci_api_data)
          if update_details.to_hash == {} # There are changes here
            Puppet.debug 'No changes in main data. Defering changes to specific properties.'
          else
            handle_oci_request do
              case object_type
              when 'tag'
                tag_namespace_id = resolver.name_to_ocid(tenant, tag_namespace_name, :tagnamespace)
                client.update_tag(tag_namespace_id, tag_name, update_details)
              when 'bucket'
                bucket_name = name.split('/').last
                client.send("update_#{object_type}", provider.namespace, bucket_name, update_details)
              else
                client.send("update_#{object_type}", provider.id, update_details)
              end
            end
          end
          nil
        end

        def on_destroy
          Puppet.debug "destroy #{object_type} #{name} "
          handle_oci_request(object_type, synchronized, provider.id) do
            case object_type
            when 'tag'
              tag_namespace_id = resolver.name_to_ocid(tenant, tag_namespace_name, :tagnamespace)
              #
              # We can only remove the tag after it has been retired. So we make
              # it one kind of operation. Maybe in the future, we can add ensure > 'retired'
              #
              client.update_tag(tag_namespace_id, tag_name, { 'isRetired' => true })
              client.delete_tag(tag_namespace_id, tag_name)
            when 'bucket'
              bucket_name = name.split('/').last
              client.send("delete_#{object_type}", provider.namespace, bucket_name)
            when 'instance'
              client.terminate_instance(provider.id)
            when 'instance_pool'
              client.terminate_instance_pool(provider.id)
            when 'vault'
              details = OCI::KeyManagement::Models::ScheduleVaultDeletionDetails.new
              client.send('schedule_vault_deletion', provider.id, details)
            when 'key'
              client.disable_key(provider.id)
            else
              client.send("delete_#{object_type}", provider.id)
            end
          end
          nil
        end

        def wait_for_work_request(wait_for_resource_id)
          Puppet.debug "Wait on work-request with id #{wait_for_resource_id}..."
          work_request_client = OCI::WorkRequests::WorkRequestClient.new(:config => tenant_config)

          OCI::Waiter::WorkRequest.wait_for_state(
            work_request_client,
            wait_for_resource_id,
            lambda do |work_request|
              Puppet.debug "Wait on work-request with id #{wait_for_resource_id}. Current status is #{work_request.status}"
              work_request.status == 'SUCCEEDED'
            end,
            lambda do |work_request|
              fail if work_request.status == 'FAILED'
            end,
            :max_interval_seconds => oci_wait_interval,
            :max_wait_seconds => oci_timeout
          )
        rescue OCI::Errors::ServiceError => e
          #
          # If we are not autorized or the resource is not found, infer the work request
          # is done and we are finished
          #
          raise unless e.service_code == 'NotAuthorizedOrNotFound'
        end

        def wait_for_state(oci_object_type, id, type)
          ready_states = type == :create ? present_states : absent_states
          ready_states << 'UNKNOWN' # Some objects don't have a state. So they are ready directly
          eval_proc = ->(response) do
            state = response.data.respond_to?(:lifecycle_state) ? response.data.lifecycle_state : 'UNKNOWN'
            if response.data.respond_to?(:puppet_name)
              Puppet.debug "Waiting for resource #{object_type} with name #{response.data.puppet_name} to become ready; Now in state #{state}."
            else
              Puppet.debug "Waiting for resource #{object_type} to become ready; Now in state #{state}."
            end
            ready_states.include?(state)
          end
          local_retry_config = case type
                               when :destroy
                                 nil
                               when :create
                                 #
                                 # When creating a resource we allow more time and retries before we signal an error
                                 # For now we use hardcoded values that are large. Means we have maximum 30 seconds for a
                                 # create before we return an error.
                                 #
                                 retry_config(tenant, 'sleep_calc_millis' => 1500, 'max_attempts' => 20)
                               else
                                 retry_config(tenant)
                               end
          waiter_result = client.send("get_#{oci_object_type}", id, :retry_config => local_retry_config)
          waiter_result.wait_until(
            :eval_proc => eval_proc,
            :max_interval_seconds => oci_wait_interval,
            :max_wait_seconds => oci_timeout
          )
        rescue OCI::Errors::ServiceError => e
          fail "#{path}: OCI raised error: #{e.message}" unless e.status_code == 404 && type == :destroy
        end

        #
        # Generates a nice error when an OCI error is raised in the yield. Also waits for the state specified in the
        # type parameter.
        #
        def handle_oci_request(oci_object_type = nil, oci_synchronized = nil, id = nil)
          oci_object_type ||= object_type
          oci_synchronized = synchronized if oci_synchronized.nil?
          begin
            operation_result = yield
          rescue OCI::Errors::ServiceError => e
            fail "#{path}: OCI raised error: #{e.message}"
          end
          wait_for_resource_id = operation_result.headers['opc-work-request-id']
          # See if we can do a synchronize
          return operation_result unless oci_synchronized

          #
          # We can synchronize, so do it.Although the post on oci_core_instance returns
          # an wait_for_resource_id, the API somehow doesn't support the wait_for_state call.
          # So that's why we just use the wait_for state call here.
          #
          if wait_for_resource_id && oci_object_type != 'instance'
            wait_for_work_request(wait_for_resource_id)
          elsif %w[bucket tag].include?(oci_object_type)
            # Do nothing. We can't sync bucket or tag operations
          elsif id.nil? # We need the id from the operation and the operation is a create or update operation
            wait_for_state(oci_object_type, operation_result.data.id, :create)
          else
            wait_for_state(oci_object_type, id, :destroy)
          end
          operation_result
        end

        private

        def resolver
          Puppet_X::EnterpriseModules::Oci::NameResolver.instance(tenant)
        end

        #
        # Returns the bare name of the object
        #
        def bare_name
          self[parameters.keys[2]]
        end

        def client
          self.class.client(tenant)
        end

        def object_type
          self.class.object_type
        end

        def parent_class
          self.class.object_class.to_s.split('::')[0...-1].join('::')
        end

        def model_class
          self.class.object_class.to_s.split('::').last
        end

        def update_class
          Kernel.const_get "#{parent_class}::Update#{model_class}Details"
        end

        def create_class
          Kernel.const_get "#{parent_class}::Create#{model_class}Details"
        end

        def launch_class
          Kernel.const_get "#{parent_class}::Launch#{model_class}Details"
        end

        def tenant_string
          "#{tenant} (root)"
        end

        # Add Documentation
        module ClassMethods
          def module_name
            'oci_config'
          end

          def execute_prefetch(resources, provider, options = {})
            tenants = resources.map { |title, _content| title.split('/').first }.uniq.map { |e| e.gsub(' (root)', '') }
            #
            # because the title of the identity tage contains not only the compartment, but also the
            # name of the tag namespace, we need an other way to calculate the compartments to search.
            # We have implemented it like this because we might use this for some other types that
            # are now a bit strange on title usage.
            #
            compartments = if MULTI_ELEMENT_PROVIDERS.include?(provider.to_s)
                             resources.map { |title, _content| title.split(%r{/|:})[1...-2].join('/') }.map { |e| e.empty? ? '/' : e }.uniq
                           else
                             resources.map { |title, _content| title.split(%r{/|:})[1...-1].join('/') }.map { |e| e.empty? ? '/' : e }.uniq
                           end
            raw_resources = tenants.collect do |tenant|
              compartments.collect do |compartment_name|
                lister = ResourceLister.new(tenant, object_class)
                resolver = Puppet_X::EnterpriseModules::Oci::NameResolver.instance(tenant)
                begin
                  compartment_id = resolver.name_to_ocid(tenant, "#{tenant} (root)/#{compartment_name}")
                rescue StandardError
                  # Skip if compartment doesn't exist
                  next
                end
                lister.resource_list(compartment_id).select(&:present?).collect do |resource|
                  hash = resource.to_hash.to_puppet
                  hash['tenant'] = tenant
                  hash
                end
              end
            end.flatten.compact
            raw_resources.each do |raw_resource|
              name_parameter_class = paramclass(:name)
              name = name_parameter_class.translate_to_resource(raw_resource) # Get the full name
              if options[:all_properties] && resources[name]
                resources[name].provider = provider.map_raw_to_resource(raw_resource)
              else
                next unless resource_names_in_manifest(resources).include?(name) # Skip if not in manifest

                specified_properties = resources[name].to_hash.reject { |key, _value| PUPPET_META_ATTRIBUTES.include?(key) }.keys
                #
                # There are anumber of properties we always need. So add them to the list
                #
                specified_properties += [:id, :compartment_id, :namespace, :subnet_id, :vcn_id, :compartment, :mount_target_id, :backup_policy_id, :volumes]
                resources[name].provider = provider.map_raw_to_resource(raw_resource, specified_properties)
              end
            end
            resources
          end

          #
          # Check if the resource names are in the manifest and if the resources
          # contain any tags that are on the list of explicit list fo tags that we need
          # or explicitly on the list of tags we want to skip.
          #
          def resource_names_in_manifest(resources)
            resources.keys.select do |name|
              if Puppet['tags'].empty?
                !resources[name].tagged?(Puppet['skip_tags'])
              else
                resources[name].tagged?(Puppet['tags']) && !resources[name].tagged?(Puppet['skip_tags'])
              end
            end
          end

          def client(tenant = nil)
            client_for(client_class, tenant)
          end

          def client_class
            ServiceInfo.type_to_client(name)
          end

          def object_class
            ServiceInfo.type_to_class(name)
          end

          def object_type
            ServiceInfo.type_to_class(name).to_s.split('::').last.underscore
          end

          def add_title_attributes(*attributes)
            full_regexp           = Regexp.new('^((.*) \\(root\\)/(.*)/(.*))$')
            top_level_regexp      = Regexp.new('^((.*) \\(root\\)/(.*))$')

            map_titles_to_attributes([
                                       full_regexp, [:name] + [:tenant] + [:compartment] + attributes,
                                       top_level_regexp, [:name] + [:tenant] + attributes
                                     ])
          end

          def get_raw_resources
            configuration.keys.collect do |tenant|
              lister = ResourceLister.new(tenant, object_class)
              lister.resource_list.select(&:present?).collect do |resource|
                hash = resource.to_hash.to_puppet
                hash['tenant'] = tenant
                hash
              end
            end.flatten.compact
          end

          def puppet_version_higher_or_equal_then(version)
            current_version = Gem::Version.new(Puppet.version)
            requested_version = Gem::Version.new(version)
            current_version >= requested_version
          end

          #
          # Based on the value of ensure, do an autorequire or an autobefore
          #
          #
          # rubocop: disable Style/NestedTernaryOperator, Style/IfInsideElse, Style/IfUnlessModifierOfIfUnless
          def child_of(id, variable = nil, &proc)
            type = ServiceInfo.id_to_type(id)
            if type.nil?
              Puppet.debug "No type found for #{id}; skipping lookup and referencing."
              return
            end
            autorequire(type) do
              begin
                present = self[:ensure].to_s == 'present'
              rescue Puppet::Error
                present = true
              end
              if variable.nil? # Always
                instance_eval(&proc) if present
              else
                self[variable].nil? || self[variable].to_s == 'absent' ? nil : instance_eval(&proc) if present
              end
            end
            if puppet_version_higher_or_equal_then('4.0.0')
              #
              # Older puppet versions don't support autobefore.
              # Because we want to be compatible with puppet 3, we will Skip
              # this functionality on older versions.
              #
              autobefore(type) do
                begin
                  absent = self[:ensure].to_s == 'absent'
                rescue Puppet::Error
                  absent = false
                end
                if absent
                  if variable.nil? # Always
                    instance_eval(&proc)
                  else
                    #
                    # Check the value of the provider is set
                    #
                    provider ? provider.send(variable).to_s == 'absent' ? nil : full_resource(provider).instance_eval(&proc) : nil
                  end
                end
              end
            else
              Puppet.debug "Skipping setting autobefore on #{type}"
            end
          end
          # rubocop: enable Style/NestedTernaryOperator, Style/IfInsideElse, Style/IfUnlessModifierOfIfUnless
        end
      end
    end
  end
end

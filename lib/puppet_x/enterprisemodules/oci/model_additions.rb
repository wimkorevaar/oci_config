# frozen_string_literal: true

module Puppet_X
  module EnterpriseModules
    module Oci
      # Docs
      module ModelAdditions
        def id_type
          id.scan(/ocid1\.(\w*)\./).first.first.to_sym
        end

        def compartment?
          [:compartment, :tenancy].include?(id_type)
        end

        #
        # The name puppet uses
        #
        def puppet_name
          if respond_to?(:name)
            name
          elsif respond_to?(:display_name)
            display_name
          elsif respond_to?(:hostname)
            hostname
          else
            'unknown name'
          end
        end

        def present?
          return true unless respond_to?(:lifecycle_state)

          %w[PROVISIONING SCALING AVAILABLE RUNNING ACTIVE ATTACHED ATTACHING ENABLED NOT_CONNECTED].include?(lifecycle_state)
        end
      end
    end
  end
end

models = [
  OCI::Budget::Models::Budget,
  OCI::Core::Models::AppCatalogSubscription,
  OCI::Core::Models::AppCatalogSubscriptionSummary,
  OCI::Core::Models::BootVolume,
  OCI::Core::Models::BootVolumeBackup,
  OCI::Core::Models::Cpe,
  OCI::Core::Models::CrossConnect,
  OCI::Core::Models::CrossConnectGroup,
  OCI::Core::Models::DedicatedVmHost,
  OCI::Core::Models::DhcpOptions,
  OCI::Core::Models::Drg,
  OCI::Core::Models::DrgRouteDistribution,
  OCI::Core::Models::DrgRouteTable,
  OCI::Core::Models::Image,
  OCI::Core::Models::Instance,
  OCI::Core::Models::InstanceConsoleConnection,
  OCI::Core::Models::InternetGateway,
  OCI::Core::Models::IPSecConnection,
  OCI::Core::Models::LocalPeeringGateway,
  OCI::Core::Models::NatGateway,
  OCI::Core::Models::NetworkSecurityGroup,
  OCI::Core::Models::RemotePeeringConnection,
  OCI::Core::Models::RouteTable,
  OCI::Core::Models::SecurityList,
  OCI::Core::Models::ServiceGateway,
  OCI::Core::Models::Service,
  OCI::Core::Models::Subnet,
  OCI::Core::Models::Vcn,
  OCI::Core::Models::VirtualCircuit,
  OCI::Core::Models::Volume,
  OCI::Core::Models::VolumeBackup,
  OCI::Core::Models::VolumeBackupPolicy,
  OCI::Core::Models::VolumeGroup,
  OCI::Core::Models::VolumeGroupBackup,
  OCI::Identity::Models::Compartment,
  OCI::Identity::Models::DynamicGroup,
  OCI::Identity::Models::Group,
  OCI::Identity::Models::IdentityProvider,
  OCI::Identity::Models::Policy,
  OCI::Identity::Models::TagNamespace,
  OCI::Identity::Models::Tag,
  OCI::Identity::Models::TagDefaultSummary,
  OCI::Identity::Models::User,
  OCI::Identity::Models::TagNamespaceSummary,
  OCI::Identity::Models::UserGroupMembership,
  OCI::Core::Models::ParavirtualizedVolumeAttachment,
  OCI::Core::Models::VolumeAttachment,
  OCI::Core::Models::BootVolumeAttachment,
  OCI::Core::Models::VnicAttachment,
  OCI::Budget::Models::BudgetSummary,
  OCI::Database::Models::AutonomousDatabaseSummary,
  OCI::KeyManagement::Models::VaultSummary,
  OCI::KeyManagement::Models::KeySummary,
  OCI::Core::Models::PublicIp,
  OCI::Core::Models::InstanceConfiguration,
  OCI::Core::Models::InstancePoolSummary,
  OCI::Autoscaling::Models::AutoScalingConfigurationSummary,
  OCI::ObjectStorage::Models::BucketSummary,
  OCI::ObjectStorage::Models::Bucket,
  OCI::FileStorage::Models::FileSystemSummary,
  OCI::FileStorage::Models::MountTargetSummary,
  OCI::FileStorage::Models::Export,
  OCI::FileStorage::Models::SnapshotSummary,
  OCI::Database::Models::DbSystemSummary,
  OCI::Database::Models::DbNodeSummary,
  OCI::Database::Models::DatabaseSummary,
  OCI::Database::Models::AutonomousContainerDatabase,
  OCI::Database::Models::ExternalContainerDatabaseSummary,
  OCI::Database::Models::ExternalNonContainerDatabaseSummary,
  OCI::Database::Models::ExternalPluggableDatabaseSummary,
  OCI::Database::Models::PluggableDatabaseSummary
].freeze

models.each do |model|
  model.class_eval { include Puppet_X::EnterpriseModules::Oci::ModelAdditions }
end

#
# The name of a tag is the name of the namespace doubld colon and then
# the name of the tag itself
#
class OCI::Identity::Models::Tag
  #
  # The name puppet uses
  #
  def puppet_name
    "#{tag_namespace_name}:#{name}"
  end
end

#
# The class doesn't have an id method, but a listing_id. So we create an alias
#
class OCI::Core::Models::AppCatalogSubscriptionSummary
  def id
    listing_id
  end
end

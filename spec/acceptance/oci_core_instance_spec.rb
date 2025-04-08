require_relative '../spec_helper_acceptance'
require_relative '../support/shared_acceptance_specs'
# rubocop: disable Style/AlignParameters 

describe 'oci_core_instance' do
  include_context 'setup'
  test_name = unique_test_name

  let(:resource_name) { "acceptance_tests/test_instance_#{test_name}" }

  before(:all) do
    manifest = <<-EOD
      oci_core_volume {['enterprisemodules (root)/acceptance_tests/test_volume_#{test_name}_1', 'enterprisemodules (root)/acceptance_tests/test_volume_#{test_name}_2']:
        ensure              => 'present',
        availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
        is_hydrated         => true,
        size_in_gbs         => 50,
      }

      oci_core_vcn { 'enterprisemodules (root)/acceptance_tests/vcn_#{test_name}':
        ensure        => 'present',
        cidr_block    => '10.0.0.0/16',
        freeform_tags => {'test' => 'yes'},
      }

      oci_core_subnet { 'enterprisemodules (root)/acceptance_tests/subnet_#{test_name}':
        ensure             => 'present',
        cidr_block         => '10.0.0.0/24',
        vcn                => 'acceptance_tests/vcn_#{test_name}',
        virtual_router_ip  => '10.0.0.2',
        virtual_router_mac => '00:00:17:9B:B0:3A',
      }

    EOD
    apply_manifest(manifest, :expect_changes => true)
  end

  after(:all) do
    manifest = <<-EOD
    oci_core_volume { ['enterprisemodules (root)/acceptance_tests/test_volume_#{test_name}_1', 'enterprisemodules (root)/acceptance_tests/test_volume_#{test_name}_2']:
      ensure       => 'absent',
      synchronized => false,
    }

    oci_core_subnet { 'enterprisemodules (root)/acceptance_tests/subnet_#{test_name}':
      ensure        => 'absent',
    }

    -> oci_core_vcn { 'enterprisemodules (root)/acceptance_tests/vcn_#{test_name}':
      ensure       => 'absent',
      synchronized => false,
    }
    EOD
    apply_manifest(manifest, :expect_changes => true)
  end


  context 'instance does not exists' do
    it 'should add the instance idempotent' do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          ssh_authorized_keys => 'ssh-rsa BBB3NzaC1y fakekey',
          user_data           => "echo 'hello there'",
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          source_details      => {
            source_type => 'image',
            image_type => 'image',
            image => oci_config::latest_image_for('Oracle Linux', '9', /9\.4-2024\./),
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          volumes             => {
            'acceptance_tests/test_volume_#{test_name}_1' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdb',
              'display_name' => 'data_disk_1',
              'is_read_only' => false,
            }
          },
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end
  end

  context "instance exists" do

    it "should add volume idempotently" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          source_details      => {
            source_type => 'image',
            image_type => 'image',
            image => oci_config::latest_image_for('Oracle Linux', '9', /9\.4-2024\./),
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          volumes             => {
            'acceptance_tests/test_volume_#{test_name}_1' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdb',
              'display_name' => 'data_disk_1',
              'is_read_only' => false,
            },
            'acceptance_tests/test_volume_#{test_name}_2' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdc',
              'display_name' => 'data_disk_2',
              'is_read_only' => false,
            }
          },
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should change attachment idempotently" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          source_details      => {
            source_type => 'image',
            image_type => 'image',
            image => oci_config::latest_image_for('Oracle Linux', '9', /9\.4-2024\./),
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          volumes             => {
            'acceptance_tests/test_volume_#{test_name}_1' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdb',
              'display_name' => 'data_disk_1',
              'is_read_only' => true,
            },
            'acceptance_tests/test_volume_#{test_name}_2' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdc',
              'display_name' => 'data_disk_2',
              'is_read_only' => false,
            }
          },
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should remove volume idempotently" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          volumes             => {},
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should attach a volume idempotently" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          attached_volumes             => {
            'acceptance_tests/test_volume_#{test_name}_1' => {
              'attachment_type' => 'paravirtualized',
              'device' => '/dev/oracleoci/oraclevdb',
              'display_name' => 'data_disk_1',
              'is_read_only' => true,
            },
          },
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should detach a volume idempotently" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure              => 'present',
          availability_domain => 'arMl:EU-FRANKFURT-1-AD-1',
          fault_domain        => 'FAULT-DOMAIN-2',
          launch_mode         => 'PARAVIRTUALIZED',
          region              => 'eu-frankfurt-1',
          shape               => 'VM.Standard.E3.Flex',
          shape_config        => {
            'ocpus'         => 1.0,
            'memory_in_gbs' => 2.0,
          },
          vnics               => {
          'nic1' => {
              'nic_index' => 0,
              'is_primary' => true,
              'skip_source_dest_check' => true,
              'subnet' => 'acceptance_tests/subnet_#{test_name}',
            }
          },
          detached_volumes             => {
            'acceptance_tests/test_volume_#{test_name}_1' => {},
          },
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should change the instance idempotent" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure        => 'present',
          freeform_tags => {'test' => 'yes'},
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should remove the instance idempotent" do
      manifest = <<-EOD
        oci_core_instance { 'enterprisemodules (root)/#{resource_name}':
          ensure => 'absent',
          oci_timeout   => 1200, # This can take a long time, so we need a longer timeout
          absent_states => ['TERMINATED'], # Really wait unit it is gone so we can remove the setup too
        }
      EOD
      apply_manifest(manifest, :expect_changes => true)
      apply_manifest(manifest, :catch_changes => true)
    end
  end
end

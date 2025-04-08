require 'spec_helper'

describe 'oci_config', :type => :class do
  context "No gem installed" do
    let(:facts) {{
      :oci_installed_gem => 'none',
    }}
    
    it { is_expected.to contain_file('/tmp/oci-2.21.1.gem')
      .with('path'   => '/tmp/oci-2.21.1.gem')
      .with('ensure' => 'present')
      .with('source' => 'puppet:///modules/oci_config/oci-2.21.1.gem')
      .that_comes_before('Package[oci]')
    }
    
    it { is_expected.to contain_package('oci')
      .with('ensure'   => '2.21.1')
      .with('provider' => 'puppet_gem')
      .with('source'   => '/tmp/oci-2.21.1.gem')
      .that_comes_before('Exec[cleanup gem source]')
    }
    
    it { is_expected.to contain_exec('cleanup gem source')
      .with('command' => '/bin/rm -f /tmp/oci-2.21.1.gem')
    }
  end

  context "Older version of gem installed" do
    let(:facts) {{
      :oci_installed_gem => '2.7.0',
    }}

    it { is_expected.to contain_file('/tmp/oci-2.21.1.gem')
      .with('path'   => '/tmp/oci-2.21.1.gem')
      .with('ensure' => 'present')
      .with('source' => 'puppet:///modules/oci_config/oci-2.21.1.gem')
      .that_comes_before('Package[oci]')
    }
    
    it { is_expected.to contain_package('oci')
      .with('ensure'   => '2.21.1')
      .with('provider' => 'puppet_gem')
      .with('source'   => '/tmp/oci-2.21.1.gem')
      .that_comes_before('Exec[cleanup gem source]')
    }
    
    it { is_expected.to contain_exec('cleanup gem source')
      .with('command' => '/bin/rm -f /tmp/oci-2.21.1.gem')
    }
  end

  context "requested version of gem already installed" do
    let(:facts) {{
      :oci_installed_gem => '2.21.1',
    }}

    it { is_expected.not_to contain_file('/tmp/oci-2.21.1.gem')}
    it { is_expected.not_to contain_package('oci')}
    it { is_expected.not_to contain_exec('cleanup gem source')}

  end
end

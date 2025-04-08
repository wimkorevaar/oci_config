alias into="docker exec -it oci_config bash"
alias stop="docker kill oci_config"
docker run --rm -d --name oci_config \
  -h oci \
  -v $PWD:/root \
  -v $PWD:/etc/puppetlabs/code/environments/production/modules/oci_config \
  -v $PWD/../easy_type:/etc/puppetlabs/code/environments/production/modules/easy_type \
  -v ~/software:/software \
  enterprisemodules/acc_base:latest /usr/sbin/init
#
docker exec oci_config rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-7.noarch.rpm
docker exec oci_config rpm -Uvh https://yum.puppet.com/puppet8-release-el-7.noarch.rpm
#
# Install bolt stuff
#
docker exec oci_config yum install gcc make puppet-agent git which puppet-bolt -y
docker exec oci_config /opt/puppetlabs/bolt/bin/gem install  specific_install byebug pry bolt
#
# handle puppet stuff
#
docker exec oci_config /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
docker exec oci_config /opt/puppetlabs/bin/puppet apply -e "include oci_config"
docker exec oci_config /opt/puppetlabs/bin/puppet apply /software/tenant_setup.pp -t
docker exec -it oci_config bash
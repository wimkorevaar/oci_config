
source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_GEM_VERSION') ? "#{ENV['PUPPET_GEM_VERSION']}" :  '8.0.1'

gem 'puppet', puppetversion, :require => false, :groups => [:test]
gem 'rake'
gem 'puppet-resource_api', :require => false
gem 'byebug'
gem 'pdk', :git => 'https://github.com/puppetlabs/pdk.git', :ref => 'main'
gem 'ffi', '< 1.17.0' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.0.0')

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.3.0')
  gem 'oci'
  gem 'activesupport',  '< 6.0.0'
  gem 'yard'
  gem 'rgen'
  gem 'puppet-strings'
end

group :unit_test do
  gem 'hiera-puppet-helper'
  gem 'rspec-puppet'
  gem 'rspec-puppet-utils'
  gem 'rspec-puppet-facts'
  gem 'concurrent-ruby', '< 1.2.0'
end

group :acceptance_test do
  gem 'bolt'
  gem 'puppet_litmus'
  gem 'serverspec'
  gem 'rspec-retry'
  gem 'parallel_tests'
end

group :release, :acceptance_test do
  gem 'puppet-blacksmith'
  gem 'em_tasks', :git => "https://github.com/enterprisemodules/em_tasks.git" if RUBY_VERSION > '2.1.2'
end

group :quality do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'fasterer'
  gem 'metadata-json-lint'
  gem 'overcommit'
  gem 'puppet-lint'
  gem 'reek'
  gem 'rubocop',  :require => false
  gem 'rubocop-performance' if Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.3.0')
end

group :unit_test, :acceptance_test, :publish do
  gem 'easy_type_helpers', :git => 'https://github.com/enterprisemodules/easy_type_helpers.git'
  gem 'puppetlabs_spec_helper'
end

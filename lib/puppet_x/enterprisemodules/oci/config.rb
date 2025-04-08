# frozen_string_literal: true

module Puppet_X
  module EnterpriseModules
    module Oci
      # Docs
      module Config
        # rubocop: disable Lint/OrAssignmentToConstant
        Puppet_X::EnterpriseModules::Oci::Settings::SETTINGS_FILE ||= '/etc/oci_tenant.yaml'
        # rubocop: enable Lint/OrAssignmentToConstant

        def client_for(klass, tenant, options = {})
          if settings_for(tenant)['instance_principal']
            instance_principals_signer = OCI::Auth::Signers::InstancePrincipalsSecurityTokenSigner.new
            full_options = { :config => tenant_config(tenant), :signer => instance_principals_signer, :retry_config => retry_config(tenant) }.merge(options)
          else
            full_options = { :proxy_settings => proxy_config(tenant), :config => tenant_config(tenant), :retry_config => retry_config(tenant) }.merge(options)
          end
          klass.new(**full_options)
        end

        def tenant_config(tenant = nil)
          OCI.logger = Logger.new($stdout) if ENV['OCI_CONFIG_DEBUG']
          tenant = self.tenant if tenant.nil?
          config_for_settings(tenant)
        end

        def proxy_config(tenant)
          extend(EasyType::Encryption)
          settings       = settings_for(tenant)
          proxy_address  = settings['proxy_address']
          proxy_port     = settings['proxy_port']
          proxy_user     = settings['proxy_user']
          proxy_password = decrypted_value(settings['proxy_password']) if settings['proxy_password']
          proxy_password ||= nil
          OCI::ApiClientProxySettings.new(proxy_address, proxy_port, proxy_user, proxy_password)
        end

        def retry_config(tenant, override = {})
          settings                          = settings_for(tenant)
          base_sleep_time_millis            = determine_setting_for('base_sleep_time_millis', override, settings, 50)
          sleep_calc_millis                 = determine_setting_for('sleep_calc_millis', override, settings, 200)
          max_attempts                      = determine_setting_for('max_attempts', override, settings, 2)
          max_elapsed_time_millis           = determine_setting_for('max_elapsed_time_millis', override, settings, 300_000)
          max_sleep_between_attempts_millis = determine_setting_for('max_sleep_between_attempts_millis', override, settings, 500)
          OCI::Retry::RetryConfig.new(
            :base_sleep_time_millis => base_sleep_time_millis,
            :exponential_growth_factor => 2,
            :sleep_calc_millis_proc => ->(_, _) { sleep_calc_millis },
            :max_attempts => max_attempts,
            :max_elapsed_time_millis => max_elapsed_time_millis,
            :max_sleep_between_attempts_millis => max_sleep_between_attempts_millis,
            :should_retry_exception_proc => ->(data) do
              return false if data.last_exception.is_a?(OCI::Errors::NetworkError)
              return false unless data.last_exception.status_code == 404

              request = data.last_exception.request_made
              Puppet.debug "retrying #{request.method} on #{request.path} for #{data.current_attempt_number + 1} time..."
              true
            end
          )
        end

        def determine_setting_for(key, override, settings, default)
          override[key] || settings[key] || default
        end

        def default_tenant
          configuration.keys.first
        end

        def settings_for(tenant)
          configuration.fetch(tenant) { fail "OCI tenant #{tenant} not defined" }
        end

        def config_for_settings(tenant)
          extend(EasyType::Encryption)
          settings = settings_for(tenant)
          config = OCI::Config.new
          #
          # Always set specified region.
          #
          config.region  = settings['region']
          config.tenancy = settings['tenancy_ocid']
          return config if settings['instance_principal']

          config.user        = settings['user_ocid']
          config.fingerprint = settings['fingerprint']
          config.key_content = decrypted_value(settings['private_key']) if settings['private_key']
          config.pass_phrase = decrypted_value(settings['private_key_password']) if settings['private_key_password']
          config
        end
      end
    end
  end
end

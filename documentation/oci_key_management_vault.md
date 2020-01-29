---
title: oci key management vault
keywords: documentation
layout: documentation
sidebar: oci_config_sidebar
toc: false
---
## Overview

A vault to manage keys.

Here is an example on how to use this:

  oci_key_management_vault { 'tenant (root)/my_vault:
    ensure        => 'present',
    vault_type    => 'DEFAULT',
  }

This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).

## Attributes



Attribute Name                                                                   | Short Description                                                                            |
-------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
[absent_states](#oci_key_management_vault_absent_states)                         | The OCI states, pupet will detect as the resource beeing absent.                             |
[compartment](#oci_key_management_vault_compartment)                             | The Puppet name of the resource identified by `compartment_id`.                              |
[compartment_id](#oci_key_management_vault_compartment_id)                       | The OCID of the compartment that contains the object.                                        |
[crypto_endpoint](#oci_key_management_vault_crypto_endpoint)                     | 
                                                                                            |
[defined_tags](#oci_key_management_vault_defined_tags)                           |   Usage of predefined tag keys.                                                              |
[disable_corrective_change](#oci_key_management_vault_disable_corrective_change) | Disable the modification of a resource when Puppet decides it is a corrective change.        |
[disable_corrective_ensure](#oci_key_management_vault_disable_corrective_ensure) | Disable the creation or removal of a resource when Puppet decides is a corrective change.    |
[ensure](#oci_key_management_vault_ensure)                                       | The basic property that the resource should be in.                                           |
[freeform_tags](#oci_key_management_vault_freeform_tags)                         |   Simple key-value pair that is applied without any predefined name, type, or scope.         |
[id](#oci_key_management_vault_id)                                               | The OCID of the resource.                                                                    |
[lifecycle_state](#oci_key_management_vault_lifecycle_state)                     | 
                                                                                            |
[management_endpoint](#oci_key_management_vault_management_endpoint)             | 
                                                                                            |
[name](#oci_key_management_vault_name)                                           | The full name of the object.                                                                 |
[oci_timeout](#oci_key_management_vault_oci_timeout)                             | The maximum time to wait for the OCI resource to be in the ready state.                      |
[oci_wait_interval](#oci_key_management_vault_oci_wait_interval)                 | The interval beween calls to OCI to check if a resource is in the ready state.               |
[present_states](#oci_key_management_vault_present_states)                       | The OCI states, pupet will detect as the resource beeing present.                            |
[provider](#oci_key_management_vault_provider)                                   | resource.                                                                                    |
[synchronized](#oci_key_management_vault_synchronized)                           | Specifies if Puppet waits for OCI actions to be ready before moving on to an other resource. |
[tenant](#oci_key_management_vault_tenant)                                       | The tenant for this resource.                                                                |
[time_created](#oci_key_management_vault_time_created)                           | 
                                                                                            |
[time_of_deletion](#oci_key_management_vault_time_of_deletion)                   | 
                                                                                            |
[vault_name](#oci_key_management_vault_vault_name)                               | The name of the vault.                                                                       |
[vault_type](#oci_key_management_vault_vault_type)                               | The type of vault to create.                                                                 |




### absent_states<a name='oci_key_management_vault_absent_states'>

The OCI states, pupet will detect as the resource beeing absent.



[Back to overview of oci_key_management_vault](#attributes)

### compartment<a name='oci_key_management_vault_compartment'>

The Puppet name of the resource identified by `compartment_id`.

See the documentation of compartment_id for all details.

This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).



[Back to overview of oci_key_management_vault](#attributes)

### compartment_id<a name='oci_key_management_vault_compartment_id'>

The OCID of the compartment that contains the object.

Rather use the property `compartment` instead of a direct OCID reference.

This documentation is generated from the Ruby OCI SDK.



[Back to overview of oci_key_management_vault](#attributes)

### crypto_endpoint<a name='oci_key_management_vault_crypto_endpoint'>





[Back to overview of oci_key_management_vault](#attributes)

### defined_tags<a name='oci_key_management_vault_defined_tags'>

  Usage of predefined tag keys. These predefined keys are scoped to namespaces.
Example: `{"foo-namespace": {"bar-key": "foo-value"}}`

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).



[Back to overview of oci_key_management_vault](#attributes)

### disable_corrective_change<a name='oci_key_management_vault_disable_corrective_change'>

Disable the modification of a resource when Puppet decides it is a corrective change.

(requires easy_type V2.11.0 or higher)

When using a Puppet Server, Puppet knows about adaptive and corrective changes. A corrective change
is when Puppet notices that the resource has changed, but the catalog has not changed. This can occur
for example, when a user, by accident or willingly, changed something on the system that Puppet is
managing. The normal Puppet process then repairs this and puts the resource back in the state as defined
in the catalog. This process is precisely what you want most of the time, but not always. This can
sometimes also occur when a hardware or network error occurs. Then Puppet cannot correctly determine
the current state of the system and thinks the resource is changed, while in fact, it is not. Letting
Puppet recreate remove or change the resource in these cases, is NOT wat you want.

Using the `disable_corrective_change` parameter, you can disable corrective changes on the current resource.

Here is an example of this:

    crucial_resource {'be_carefull':
      ...
      disable_corrective_change => true,
      ...
    }

When a corrective ensure does happen on the resource Puppet will not modify the resource
and signal an error:

        Error: Corrective change present requested by catalog, but disabled by parameter disable_corrective_change
        Error: /Stage[main]/Main/Crucial_resource[be_carefull]/parameter: change from '10' to '20' failed: Corrective change present requested by catalog, but disabled by parameter disable_corrective_change. (corrective)



[Back to overview of oci_key_management_vault](#attributes)

### disable_corrective_ensure<a name='oci_key_management_vault_disable_corrective_ensure'>

Disable the creation or removal of a resource when Puppet decides is a corrective change.

(requires easy_type V2.11.0 or higher)

When using a Puppet Server, Puppet knows about adaptive and corrective changes. A corrective change
is when Puppet notices that the resource has changed, but the catalog has not changed. This can occur
for example, when a user, by accident or willingly, changed something on the system that Puppet is
managing. The normal Puppet process then repairs this and puts the resource back in the state as defined
in the catalog. This process is precisely what you want most of the time, but not always. This can
sometimes also occur when a hardware or network error occurs. Then Puppet cannot correctly determine
the current state of the system and thinks the resource is changed, while in fact, it is not. Letting
Puppet recreate remove or change the resource in these cases, is NOT wat you want.

Using the `disable_corrective_ensure` parameter, you can disable corrective ensure present or ensure absent actions on the current resource.

Here is an example of this:

    crucial_resource {'be_carefull':
      ensure                    => 'present',
      ...
      disable_corrective_ensure => true,
      ...
    }

When a corrective ensure does happen on the resource Puppet will not create or remove the resource
and signal an error:

        Error: Corrective ensure present requested by catalog, but disabled by parameter disable_corrective_ensure.
        Error: /Stage[main]/Main/Crucial_resource[be_carefull]/ensure: change from 'absent' to 'present' failed: Corrective ensure present requested by catalog, but disabled by parameter disable_corrective_ensure. (corrective)



[Back to overview of oci_key_management_vault](#attributes)

### ensure<a name='oci_key_management_vault_ensure'>

The basic property that the resource should be in.

Valid values are `present`, `absent`. 

[Back to overview of oci_key_management_vault](#attributes)

### freeform_tags<a name='oci_key_management_vault_freeform_tags'>

  Simple key-value pair that is applied without any predefined name, type, or scope.
Exists for cross-compatibility only.
Example: `{"bar-key": "value"}`

  This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).



[Back to overview of oci_key_management_vault](#attributes)

### id<a name='oci_key_management_vault_id'>

The OCID of the resource. This is a read-only property.

This documentation is generated from the Ruby OCI SDK.



[Back to overview of oci_key_management_vault](#attributes)

### lifecycle_state<a name='oci_key_management_vault_lifecycle_state'>





[Back to overview of oci_key_management_vault](#attributes)

### management_endpoint<a name='oci_key_management_vault_management_endpoint'>





[Back to overview of oci_key_management_vault](#attributes)

### name<a name='oci_key_management_vault_name'>

The full name of the object.



[Back to overview of oci_key_management_vault](#attributes)

### oci_timeout<a name='oci_key_management_vault_oci_timeout'>

The maximum time to wait for the OCI resource to be in the ready state.



[Back to overview of oci_key_management_vault](#attributes)

### oci_wait_interval<a name='oci_key_management_vault_oci_wait_interval'>

The interval beween calls to OCI to check if a resource is in the ready state.



[Back to overview of oci_key_management_vault](#attributes)

### present_states<a name='oci_key_management_vault_present_states'>

The OCI states, pupet will detect as the resource beeing present.



[Back to overview of oci_key_management_vault](#attributes)

### provider<a name='oci_key_management_vault_provider'>

The specific backend to use for this `oci_key_management_vault`
resource. You will seldom need to specify this --- Puppet will usually
discover the appropriate provider for your platform.Available providers are:

sdk
: 



[Back to overview of oci_key_management_vault](#attributes)

### synchronized<a name='oci_key_management_vault_synchronized'>

Specifies if Puppet waits for OCI actions to be ready before moving on to an other resource.



[Back to overview of oci_key_management_vault](#attributes)

### tenant<a name='oci_key_management_vault_tenant'>

The tenant for this resource.



[Back to overview of oci_key_management_vault](#attributes)

### time_created<a name='oci_key_management_vault_time_created'>





[Back to overview of oci_key_management_vault](#attributes)

### time_of_deletion<a name='oci_key_management_vault_time_of_deletion'>





[Back to overview of oci_key_management_vault](#attributes)

### vault_name<a name='oci_key_management_vault_vault_name'>

The name of the vault.



[Back to overview of oci_key_management_vault](#attributes)

### vault_type<a name='oci_key_management_vault_vault_type'>

The type of vault to create. Each type of vault stores the key with different degrees of isolation and has different options and pricing.

This documentation is generated from the [Ruby OCI SDK](https://github.com/oracle/oci-ruby-sdk).



[Back to overview of oci_key_management_vault](#attributes)
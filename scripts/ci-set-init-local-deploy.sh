#!/bin/bash

function to_abs_path {
    local target="$1"
    if [ "$target" == "." ]; then
        echo "$(pwd)"
    elif [ "$target" == ".." ]; then
        echo "$(dirname "$(pwd)")"
    else
        echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    fi
}

config_override=$(to_abs_path $TF_VAR_firehawk_path/../secrets/config-override-$TF_VAR_envtier) # ...Config Override path $config_override.
echo "config_override path- $config_override"
sed -i 's/^TF_VAR_enable_vpc=.*$/TF_VAR_enable_vpc=false/' $config_override # ...Enable the vpc.
sed -i 's/^TF_VAR_softnas_storage=.*$/TF_VAR_softnas_storage=false/' $config_override # ...On first apply, don't create softnas instance until vpn is working.
sed -i 's/^TF_VAR_site_mounts=.*$/TF_VAR_site_mounts=false/' $config_override # ...Site mounts will not be mounted in cloud.  currently this will disable provisioning any render node or remote workstation until vpn is confirmed to function after this step.
sed -i 's/^TF_VAR_remote_mounts_on_local=.*$/TF_VAR_remote_mounts_on_local=false/' $config_override # ...Softnas nfs exports will not be mounted on local site
sed -i 's/^TF_VAR_provision_deadline_spot_plugin=.*$/TF_VAR_provision_deadline_spot_plugin=true/' $config_override # Deadline must be installed or houdini install may fail since it will attempt to install deadline plugins.  this can be updated in future
sed -i 's/^TF_VAR_install_houdini=.*$/TF_VAR_install_houdini=true/' $config_override # install houdini
sed -i 's/^TF_VAR_taint_single=.*$/TF_VAR_taint_single=(module.firehawk_init.null_resource.install-houdini-local-workstation[0])/' $config_override # taint vpn
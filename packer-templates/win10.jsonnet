local util = import 'util.libsonnet';

function(vm_name='windows10', memory=5120, zscaler=false)
    util.makevm(vm_name=vm_name,
                guest_os_type_vmware='windows9-64',
                iso_url=util.params.win10.iso_url,
                iso_checksum=util.params.win10.iso_checksum,
                memory=memory,
                vmx_data={firmware: "efi"},
                zscaler=zscaler)

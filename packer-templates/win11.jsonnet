local util = import 'util.libsonnet';

function(vm_name='windows11', memory=5120, zscaler=false)
    util.makevm(vm_name=vm_name,
                guest_os_type_vmware='windows11-64',
                iso_url=util.params.win11.iso_url,
                iso_checksum=util.params.win11.iso_checksum,
                memory=memory,
                vmx_data={firmware: "efi"},
                zscaler=zscaler)

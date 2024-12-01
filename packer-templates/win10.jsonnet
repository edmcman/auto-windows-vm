local util = import 'util.libsonnet';

function(zscaler=false)
    util.makevm(vm_name='windows10',
                guest_os_type_vmware='windows9-64',
                iso_url=util.params.win10.iso_url,
                iso_checksum=util.params.win10.iso_checksum,
                memory=5120,
                vmx_data={firmware: "efi"},
                zscaler=zscaler)

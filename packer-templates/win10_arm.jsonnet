local util = import 'util.libsonnet';

function(vm_name='windows10', memory=5120, zscaler=false)
  util.makevm(vm_name=vm_name,
              guest_os_type_vmware='arm-windows11-64',
              guest_os_type_virtualbox='Windows10_arm64',
              iso_url=util.params.win10_arm.iso_url,
              iso_checksum=util.params.win10_arm.iso_checksum,
              memory=memory,
              zscaler=zscaler)

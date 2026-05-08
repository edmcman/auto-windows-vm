local util = import 'util.libsonnet';

function(vm_name='windows11', memory=5120, options={})
  util.makevm(vm_name=vm_name,
              guest_os_type_vmware='windows11-64',
              guest_os_type_virtualbox='Windows11_64',
              iso_url=util.params.win11.iso_url,
              iso_checksum=util.params.win11.iso_checksum,
              autounattend_path=util.params.win11.autounattend_path,
              memory=memory,
              options=options)

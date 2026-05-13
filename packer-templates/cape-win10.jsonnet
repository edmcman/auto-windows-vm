local util = import 'util.libsonnet';

function(vm_name='cape-win10', memory=4096, options={})
  util.makevm(vm_name=vm_name,
              guest_os_type_vmware='windows9-64',
              guest_os_type_virtualbox='Windows10_64',
              iso_url=util.params.win10.iso_url,
              iso_checksum=util.params.win10.iso_checksum,
              autounattend_path=util.params.win10.autounattend_path,
              memory=memory,
              options=options { cape: {} })
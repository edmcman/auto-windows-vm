local util = import 'util.libsonnet';

util.makevm(vm_name='windows11',
            guest_os_type='windows11-64',
            iso_url=util.params.win11.iso_url,
            iso_checksum=util.params.win11.iso_checksum,
            memory=5120,
            vmx_data={firmware: "efi"})

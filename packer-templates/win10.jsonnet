local util = import 'util.libsonnet';

util.makevm(guest_os_type='windows9-64',
            iso_url=util.params.win10.iso_url,
            iso_checksum=util.params.win10.iso_checksum,
            winrm_username='vagrant',
            winrm_password='vagrant',
            memory=5120,
            cpus=2,
            vmx_data={firmware: "efi"})

{
  params: {
    win11: {
      iso_url: "https://software-download.microsoft.com/download/sg/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso",
      iso_checksum: "e8b1d2a1a85a09b4bf6154084a8be8e3c814894a15a7bcf3e8e63fcfa9a528cb"
    },
    win10: {
      iso_url: "https://software-download.microsoft.com/download/pr/19043.1165.210529-1549.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso",
      iso_checksum: "026607e7aa7ff80441045d8830556bf8899062ca9b3c543702f112dd6ffe6078"
    }
  },
  makevm: function(guest_os_type, iso_url, iso_checksum, vm_name='ed-vm', winrm_username='ed', winrm_password='password', vmx_data={}, disk_adapter_type='nvme', memory=5120, cpus=2, version=21) {
    builders: [{
      type: 'vmware-iso',
      memory: memory,
      cpus: cpus,
      guest_os_type: guest_os_type,
      disk_adapter_type: disk_adapter_type,

      snapshot_name: "clean-install",

      vm_name: vm_name,

      version: version,

      boot_wait: "1s",
      boot_command: "<spacebar>",

      vmx_data: vmx_data,

      shutdown_command: "shutdown /p",

      iso_url: iso_url,
      iso_checksum: iso_checksum,
      communicator: 'winrm',
      headless: 'false',
      winrm_username: winrm_username,
      winrm_password: winrm_password,
      winrm_insecure: 'true',
      winrm_use_ssl: 'false',

      winrm_timeout: '12h',
      floppy_files: [
        'files/autounattend.xml',
        'scripts/install-boxstarter.ps1',
        'files/vm.boxstarter',
      ],
    }],
  },
}

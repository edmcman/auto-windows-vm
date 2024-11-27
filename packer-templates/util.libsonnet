{
  params: {
    win11: {
      iso_url: 'https://software-download.microsoft.com/download/sg/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso',
      iso_checksum: 'e8b1d2a1a85a09b4bf6154084a8be8e3c814894a15a7bcf3e8e63fcfa9a528cb',
    },
    win10: {
      iso_url: 'https://software-download.microsoft.com/download/pr/19043.1165.210529-1549.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso',
      iso_checksum: '026607e7aa7ff80441045d8830556bf8899062ca9b3c543702f112dd6ffe6078',
    },
  },
  makevm: function(guest_os_type_vmware, iso_url, iso_checksum, vm_name='ed-vm', winrm_username='ed', winrm_password='password', vmx_data={}, disk_size_mb=100*1024, memory=8*1024, cpus=2, vmware_version=21)
    local common = {
      memory: memory,
      cpus: cpus,
      vm_name: vm_name,

      disk_size: disk_size_mb,

      boot_wait: '1s',
      boot_command: '<spacebar>',

      iso_url: iso_url,
      iso_checksum: iso_checksum,

      // Because of limitations in the vmware-iso builder, disabling WinRM must
      // happen in the shutdown command.  Otherwise the builder will attempt (and
      // fail) to run the shutdown command which will fail because WinRM is turned
      // off.
      shutdown_command: 'powershell -executionpolicy bypass -file C:/windows/temp/disable-winrm-and-shutdown.ps1',

      communicator: 'winrm',
      headless: 'false',
      winrm_username: winrm_username,
      winrm_password: winrm_password,
      winrm_insecure: 'true',
      winrm_use_ssl: 'false',
      winrm_timeout: '2h',
      floppy_files: [
        'files/autounattend.xml',
        'files/vm.boxstarter',
        'scripts/enable-winrm.ps1',  // called by vm.boxstarter
        'scripts/install-boxstarter.ps1',
	'scripts/early.ps1',
	// 'scripts/ed/zscaler-mitm.ps1'
      ],
    };

    {
      builders: [
        common {
          type: 'vmware-iso',
          guest_os_type: guest_os_type_vmware,
          disk_adapter_type: 'nvme',
          snapshot_name: 'clean-install',
          output_directory: 'output-vmware-' + vm_name,
          vm_name: vm_name,
          version: vmware_version,
          vmx_data: vmx_data,
        },
      ],
      provisioners: [
        {
          type: 'powershell',
          scripts: ['scripts/cleanup.ps1'],
        },
        {
          type: 'file',
          source: 'scripts/disable-winrm-and-shutdown.ps1',
          destination: 'c:/windows/temp/disable-winrm-and-shutdown.ps1',
        },
      ],
    },

}

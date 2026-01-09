{
  params: {
    // This site is quite helpful for finding ISOs.
    // https://ru.files.rg-adguard.net/file/a6329578-0cd5-4256-4377-fc8e82882184
    win11: {
      iso_url: 'https://aka.ms/Win11E-ISO-25H2-en-us',
      iso_checksum: 'sha256:a61adeab895ef5a4db436e0a7011c92a2ff17bb0357f58b13bbc4062e535e7b9',
    },
    win11_arm: {
      iso_url: 'https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENT_CONSUMER_a64fre_en-us.iso',
      iso_checksum: 'sha256:32cde0071ed8086b29bb6c8c3bf17ba9e3cdf43200537434a811a9b6cc2711a1',
    },
    win10: {
      iso_url: 'https://archive.org/download/windows_10_version_2004/Windows%2010%2C%20version%2022H2/Updated%20October%202025%20%2819045.6456%29/en-us_windows_10_business_editions_version_22h2_updated_oct_2025_x64_dvd_d2eef4b0.iso',
      iso_checksum: 'sha256:2c23bc8b95a9314f15ebff881dcbea49651f52a96a0327d7aaf523aa66043765',
    },
    win10_arm: {
      iso_url: 'https://archive.org/download/windows_10_version_2004/Windows%2010%2C%20version%2022H2/Updated%20October%202025%20%2819045.6456%29/SW_DVD9_Win_Pro_10_22H2.36_Arm64_English_Pro_Ent_EDU_N_MLF_X24-17199.iso',
      iso_checksum: 'sha256:465109120d93738598faf72193193d66d6577278406f4ffa75642e472985a486',
    }
  },
  makevm: function(guest_os_type_vmware, iso_url, iso_checksum, vm_name='ed-vm', winrm_username='ed', winrm_password='password', vmx_data={}, disk_size_mb=100 * 1024, memory=8 * 1024, cpus=2, vmware_version=21, zscaler=false, guest_os_type_virtualbox, vboxmanage=[])
    local isArm = guest_os_type_vmware == 'arm-windows11-64' || guest_os_type_virtualbox == 'Windows11_arm64';
    local autounattend_path = if isArm then 'files/autounattend/arm64/autounattend.xml' else 'files/autounattend/amd64/autounattend.xml';
    local vmware_vmx_data = vmx_data {
      'sata1.present': 'TRUE',
    };
    local common = {
      memory: memory,
      cpus: cpus,
      vm_name: vm_name,

      disk_size: disk_size_mb,

      boot_wait: '1s',
      boot_command: '<spacebar><wait1><spacebar><wait1><spacebar>',

      iso_url: iso_url,
      iso_checksum: iso_checksum,

      // Because of limitations in the vmware-iso builder, disabling WinRM must
      // happen in the shutdown command.  Otherwise the builder will attempt
      // (and fail) to run the shutdown command which will fail because WinRM is
      // turned off.  Additionally, vmware fusion seems more sensitive to being
      // disconnected while running the shutdown command, so we use CIM to run
      // the script in the background.
      shutdown_command: "powershell -Command \"Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'powershell.exe -ExecutionPolicy Bypass -File C:/windows/temp/disable-winrm-and-shutdown.ps1' }\"",

      communicator: 'winrm',
      headless: 'false',
      winrm_username: winrm_username,
      winrm_password: winrm_password,
      winrm_insecure: 'true',
      winrm_use_ssl: 'false',
      winrm_timeout: '2h',
      cd_files:
        [
          autounattend_path,
          'files/vm.boxstarter',
          'scripts/enable-winrm.ps1',  // called by vm.boxstarter
          'scripts/install-boxstarter.ps1',
        ] +
        (if zscaler then ['scripts/ed/zscaler-mitm.ps1'] else []),
    };

    {
      builders: [
        // VMware ISO builder
        common {
          type: 'vmware-iso',


          // add fusion drivers
          cd_files+: (if isArm then ['files/drivers/arm64-fusion/*'] else []),

          // TODO: Figure out how to install vmware-tools for fusion on arm
          cd_content: if isArm then {} else {
            'vars.ps1': "$VMPACKAGE = 'vmware-tools'\n",
          },
          guest_os_type: guest_os_type_vmware,
        } +

        (if isArm then {
           // per https://github.com/hashicorp/packer-plugin-vmware/tree/main/example/iso#vmware-fusion-pro-on-apple-silicon
           network_adapter_type: 'vmxnet3',
           vmx_data: vmware_vmx_data {
             'usb_xhci.present': 'TRUE',
           },
           usb: true,

         }
         else
           { vmx_data: vmware_vmx_data }) +
        {
          cdrom_adapter_type: 'sata',
          disk_adapter_type: 'nvme',
          firmware: 'efi',
          //network: 'nat',
          snapshot_name: 'clean-install',
          output_directory: 'output-vmware-' + vm_name,
          vm_name: vm_name,
          version: vmware_version,
        },
        // VirtualBox ISO builder
        common {
          type: 'virtualbox-iso',
          cd_content: {
            'vars.ps1': "$VMPACKAGE = 'virtualbox-guest-additions-guest.install'\n",
          },
          guest_os_type: guest_os_type_virtualbox,
          output_directory: 'output-virtualbox-' + vm_name,
          vm_name: vm_name,
          firmware: 'efi',
          vboxmanage: vboxmanage + [
            ['modifyvm', '{{.Name}}', '--usb-ohci=off'],
            ['modifyvm', '{{.Name}}', '--usb-xhci=on'],
            ['modifyvm', '{{.Name}}', '--keyboard=usb'],
            ['modifyvm', '{{.Name}}', '--mouse=usb'],
          ],
          hard_drive_interface: 'sata',
          iso_interface: 'sata',
          usb: true,
          keep_registered: true,
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
      "post-processors": [
        {
          type: 'vagrant',
          keep_input_artifact: true,
          output: 'boxes/{{.Provider}}-%s.box' % vm_name,
          vagrantfile_template: 'packer-templates/Vagrantfile.template',
        },
      ],
    },

}

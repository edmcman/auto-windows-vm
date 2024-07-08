# Automation to create a Windows VM using Packer & Boxstarter

I intend this repository to be a simple way to reproduce my preferred VM setup.
I use Packer to create a Windows 10 VM and Boxstarter to install software and
configure the system.

Fish: `packer build (jsonnet packer-templates/win10.jsonnet | psub)`

Bash: `packer build <(jsonnet packer-templates/win10.jsonnet)`

# Configuration

You can adjust the settings and software installed by modifying the
[files/vm.boxstarter](files/vm.boxstarter) file and the helper scripts that it
invokes [scripts/install-packages.ps1](scripts/install-packages.ps1).

# Testing

I have tested this on a Ubuntu 22.04.4 LTS host with Packer v1.11.1 and VMWare
Workstation 17.5.2 Pro.

# Todo

* Support for virtualbox
* Automatically modify autounattend.xml as needed to call boxstarter, add TPM bypass

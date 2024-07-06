# Automation to create a Windows VM using Packer & Boxstarter

I intend this repository to be a simple way to reproduce my preferred VM setup.
I use Packer to create a Windows 10 VM and Boxstarter to install software and
configure the system.

Fish: `packer build (jsonnet packer-templates/win10.jsonnet | psub)`

Bash: `packer build <(jsonnet packer-templates/win10.jsonnet)`

# Todo

* Support for other builders besides `vmware-iso`
* Windows 11 support
* Don't require user to press key to boot from CD
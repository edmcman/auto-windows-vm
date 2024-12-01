# Automation to create a Windows VM using Packer & Boxstarter

I intend this repository to be a simple way to reproduce my preferred VM setup.
I use Packer to create a Windows 10 VM and Boxstarter to install software and
configure the system.

Fish: `packer build (jsonnet packer-templates/win10.jsonnet | psub)`

Bash: `packer build <(jsonnet packer-templates/win10.jsonnet)`

# Configuration

You can adjust the settings and software installed by modifying the
[files/vm.boxstarter](files/vm.boxstarter) file.

You can also adjust the following parameters from the command line:
* `vm_name`
* `memory` (RAM in MiB)
* `zscaler` (install Zscaler MitM certificate)

To set these, add `--tla-code parameter=value` to the `jsonnet` command.  For
example: `jsonnet --tla-code zscaler=true packer-templates/win10.jsonnet` will
install the Zscaler MitM certificate.

# Testing

I have tested this on a Ubuntu 22.04.4 LTS host with Packer v1.11.1 and VMWare
Workstation 17.5.2 Pro.

# Todo

* Support for virtualbox
* Automatically modify autounattend.xml as needed to call boxstarter, add TPM bypass [using manifestXmlJsonml?](https://jsonnet.org/ref/stdlib.html)
* Allow different package lists for different VMs... somehow
* Add [GitHub Actions](https://github.com/jonashackt/vagrant-github-actions) to test the build for VirtualBox

Observation: A lot of these issues could be solved by [generating multiple
files](https://jsonnet.org/learning/getting_started.html) from a single jsonnet
file.  We wouldn't be able to pipe the output, but that's probably okay.
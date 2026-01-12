# Automation to create a Windows VM using Packer & Boxstarter

I intend this repository to be a simple way to reproduce my preferred VM setup.
I use Packer to create a Windows 10 VM and Boxstarter to install software and
configure the system.

Fish: `packer build (jsonnet packer-templates/win10.jsonnet | psub)`

Bash: `packer build <(jsonnet packer-templates/win10.jsonnet)`

# Configuration

You can adjust the settings and software installed by modifying the
[files/vm.boxstarter](files/vm.boxstarter) file.

You can also adjust the following parameters from the command line. Some are top-level TLA parameters passed directly to the template (for example `vm_name` and `memory`), while others are meant to be set inside the `options` object (for example `zscaler` and `enable_winrm`).

Parameters:
* `vm_name` — VM name (top-level TLA parameter)
* `memory` (RAM in MiB) — top-level TLA parameter
* `zscaler` (install Zscaler MitM certificate) — default: `false` (set via `options`)
* `enable_winrm` (leave WinRM enabled during shutdown) — default: `false` (set via `options`) 
* `enable_sshd` (install and enable OpenSSH Server via Boxstarter) — default: `false` (set via `options`)

To set top-level parameters, pass them using `--tla-code` (examples):
`jsonnet --tla-code vm_name='customvm' --tla-code memory=8192 packer-templates/win10.jsonnet`

To set `options`, pass an `options` object via `--tla-code` (example):
`jsonnet --tla-code options='{zscaler: true, enable_winrm: true, enable_sshd: true}' packer-templates/win10.jsonnet`

You can combine both approaches in a single invocation:
`jsonnet --tla-code vm_name='customvm' --tla-code memory=8192 --tla-code options='{zscaler: true, enable_winrm: true}' packer-templates/win10.jsonnet`

# Testing

I have tested this on a Ubuntu 22.04.4 LTS host with Packer v1.11.1 and VMWare
Workstation 17.5.2 Pro and 17.6.3 Pro. Windows 11 ARM is also supported on
VMware Fusion (tested on Professional 25H2). There is some code for using
VirtualBox as a builder, but it is poorly tested.

To generate a VMWare-only build (or to explicitly choose a builder), use
the `-only` flag when invoking `packer build`. For example, after generating
the template with `jsonnet`:

Fish:
```
packer build -only=vmware-iso (jsonnet packer-templates/win10.jsonnet | psub)
```

Bash:
```
packer build -only=vmware-iso <(jsonnet packer-templates/win10.jsonnet)
```

If you want to produce both VMware and VirtualBox images in one run, run
`packer build` without the `-only` flag and both builders configured in
the JSON template will be executed.

# Todo

* Automatically modify autounattend.xml as needed to call boxstarter, add TPM bypass [using manifestXmlJsonml?](https://jsonnet.org/ref/stdlib.html)
* Allow different package lists for different VMs... somehow
* Add [GitHub Actions](https://github.com/jonashackt/vagrant-github-actions) to test the build for VirtualBox

Observation: A lot of these issues could be solved by [generating multiple
files](https://jsonnet.org/learning/getting_started.html) from a single jsonnet
file.  We wouldn't be able to pipe the output, but that's probably okay.
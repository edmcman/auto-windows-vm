# AGENTS.md

## Build Commands

Generate a Packer template from Jsonnet and build a VM:

**Fish:**
```
packer build (jsonnet packer-templates/win10.jsonnet | psub)
packer build (jsonnet packer-templates/win11.jsonnet | psub)
```

**Bash:**
```
packer build <(jsonnet packer-templates/win10.jsonnet)
packer build <(jsonnet packer-templates/win11.jsonnet)
```

ARM variants: `win10_arm.jsonnet`, `win11_arm.jsonnet`

Override TLA parameters:
```
jsonnet --tla-code vm_name='customvm' --tla-code memory=8192 packer-templates/win10.jsonnet
jsonnet --tla-code options='{zscaler: true, enable_winrm: true, enable_sshd: true}' packer-templates/win10.jsonnet
```

Build only VMware (skip VirtualBox/QEMU):
```
packer build -only=vmware-iso <(jsonnet packer-templates/win10.jsonnet)
```

## Architecture

**Jsonnet-driven Packer templates.** The core logic lives in `packer-templates/util.libsonnet`, which defines a `makevm` function that generates a Packer JSON config with multiple builders (vmware-iso, virtualbox-iso, qemu), provisioners, and a Vagrant post-processor. The per-OS `.jsonnet` files (win10, win11, and their ARM variants) are thin wrappers that call `makevm` with OS-specific parameters (ISO URL, checksum, guest OS type, autounattend path).

**Template parameters** are passed as top-level arguments (TLAs) to Jsonnet:
- `vm_name`, `memory` — top-level TLA parameters
- `options` — an object with keys `zscaler`, `enable_winrm`, `enable_sshd`

**Provisioning pipeline** (runs inside the VM):
1. `autounattend.xml` drives unattended Windows install (separate XML for amd64 vs arm64)
2. `scripts/install-boxstarter.ps1` bootstraps Boxstarter and runs `files/vm.boxstarter`
3. `files/vm.boxstarter` installs packages (choco), applies settings, optionally enables SSH, runs Windows Update
4. `scripts/cleanup.ps1` wipes temp files and zero-frees disk space
5. `scripts/disable-winrm-and-shutdown.ps1` optionally disables WinRM then shuts down

**ARM differences** — ARM builds add VMware Fusion drivers from `files/drivers/arm64-fusion/` to the CD, and configure `vmxnet3` network adapter + USB xHCI. ARM64 is unsupported for VMware on Windows 10.

**QEMU/KVM builder** — Uses q35 machine type, OVMF UEFI firmware, e1000e NIC, and Hyper-V enlightenments via CPU flags.

**Output** — Packer produces VMware/VirtualBox/QEMU VMs and Vagrant `.box` files in `boxes/`. Build artifacts go to `output-vmware-*`, `output-virtualbox-*`, `output-qemu-*` (gitignored).

## Key Files

- `packer-templates/util.libsonnet` — All builder/provisioner logic; the single source of truth for VM configuration
- `files/vm.boxstarter` — Package list and Windows settings customization
- `files/autounattend/{amd64,arm64}/autounattend.xml` — Unattended Windows install answers
- `scripts/` — PowerShell scripts run inside the VM during provisioning
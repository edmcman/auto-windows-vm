local util = import 'util.libsonnet';

// Must match win10_guest_* in variables.pkrvars.hcl (used by the CAPE VM build).
local capeMac     = '52:54:00:ca:fe:10';
local capeIp      = '192.168.56.10';
local capeGateway = '192.168.56.1';
local capePrefix  = 24;

function(vm_name='cape-win10', memory=4096, options={})
  util.makevm(vm_name=vm_name,
              guest_os_type_vmware='windows9-64',
              guest_os_type_virtualbox='Windows10_64',
              iso_url=util.params.win10.iso_url,
              iso_checksum=util.params.win10.iso_checksum,
              autounattend_path=util.params.win10.autounattend_path,
              memory=memory,
              mac_address=capeMac,
              static_ip=capeIp,
              gateway=capeGateway,
              prefix_length=capePrefix,
              options=options { cape: true })

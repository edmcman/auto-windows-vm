# Automation to create a Windows VM using Packer & Boxstarter

Fish: `packer build (jsonnet packer-templates/win10.jsonnet | psub)`
Bash: `packer build <(jsonnet packer-templates/win10.jsonnet)`
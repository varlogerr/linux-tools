# <a id="top"></a>Linux tools

Set of tools for Linux configuration

## Categories

* [Proxmox](#proxmox)
  * [PVE helper install](#pve-helper-install)
  * [PVE post install](#pve-post-install)

## Proxmox

Proxmox tools

### PVE helper install

  Installs all the tools from [Proxmox](#proxmox) section, plus a set of PVE helpers. Lanuch on PVE host:
  ```sh
  wget https://github.com/varlogerr/proxmox-tools/raw/master/proxmox/pve-tool-helper-install.sh
  chmod +x ./pve-tool-helper-install.sh
  ./pve-tool-helper-install.sh -h
  ```

  After helpers installation reload your environment with `. ~/.bashrc` and inspect newly installed tools with `pve-tool-ls.sh` command.

[To top]

### PVE post install

PVE after installation configuration. Lanuch on PVE host:
```sh
wget https://github.com/varlogerr/proxmox-tools/raw/master/proxmox/pve-tool-post-install.sh
chmod +x ./pve-tool-post-install.sh
./pve-tool-post-install.sh -h
```

[To top]

[To top]: #top

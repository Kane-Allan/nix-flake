Work Laptop Dual Boot Install

Use the NixOS minimal ISO for this install. The graphical ISO is fine if you want a browser or GUI tools, but the minimal ISO is the better fit for a flake-based manual install.

Target Layout

For a 512 GB SSD:

- Windows EFI System Partition: created by Windows, FAT32, mounted by NixOS at /boot/efi
- Microsoft Reserved: created by Windows
- Windows C: 200 GB NTFS
- Windows recovery: created by Windows if it wants one
- Shared: 50 GB NTFS, label Shared, mounted by NixOS at /mnt/shared
- NixOS /boot: 2 GiB ext4, label nixos-boot, mounted at /boot
- NixOS root: rest of disk, LUKS + ext4, label nixos-root, mounted at /

Windows First

1. Boot the Windows installer in UEFI mode.
2. Choose Custom / Advanced install.
3. Delete existing partitions only if this disk is safe to wipe.
4. Create only the Windows C: partition as 204800 MB.
5. Let Windows create its EFI/MSR/recovery partitions.
6. Finish Windows install.
7. Boot Windows once.
8. Disable Fast Startup: Control Panel -> Power Options -> Choose what power buttons do -> disable Fast Startup.
9. If BitLocker is enabled, save the recovery key and suspend BitLocker before installing NixOS.
10. Open Disk Management.
11. Create a 50 GB NTFS partition from unallocated space and label it Shared.
12. Leave the rest of the disk unallocated for NixOS.

NixOS Install

Boot the NixOS minimal ISO in UEFI mode.

Become root if needed:

```sh
sudo -i
```

Connect to the network. Wired should usually work automatically. For Wi-Fi, try:

```sh
systemctl start NetworkManager
nmtui
```

Verify network access:

```sh
ping -c 3 nixos.org
```

Identify the disk and existing Windows partitions:

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,PARTTYPENAME,MOUNTPOINTS
```

Assume the internal disk is /dev/nvme0n1 only after verifying it. Partition numbers below are examples; do not copy them blindly.

Create the two NixOS partitions in the remaining unallocated space:

```sh
cfdisk /dev/nvme0n1
```

Inside cfdisk:

1. Select the free space after Windows and Shared.
2. Create a 2 GiB Linux filesystem partition for NixOS /boot.
3. Create a second Linux filesystem partition using the remaining free space for NixOS root.
4. Write the partition table.
5. Quit.

Reload the partition table and verify the new partition names:

```sh
partprobe /dev/nvme0n1
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,PARTTYPENAME,MOUNTPOINTS
```

Set variables for the real partition names. These are examples only:

```sh
ESP=/dev/nvme0n1p1
NIXBOOT=/dev/nvme0n1p6
NIXROOT=/dev/nvme0n1p7
```

Do not format the Windows EFI partition, Windows C:, Windows recovery, or Shared partition.

Format NixOS /boot:

```sh
mkfs.ext4 -L nixos-boot "$NIXBOOT"
```

Encrypt and format NixOS root:

```sh
cryptsetup luksFormat "$NIXROOT"
cryptsetup open "$NIXROOT" nixos-root
mkfs.ext4 -L nixos-root /dev/mapper/nixos-root
```

Mount the install target:

```sh
mount /dev/mapper/nixos-root /mnt
mkdir -p /mnt/boot /mnt/boot/efi /mnt/home/kane
mount /dev/disk/by-label/nixos-boot /mnt/boot
mount "$ESP" /mnt/boot/efi
```

Do not mount the Shared partition before generating hardware-configuration.nix. The flake already declares it at /mnt/shared.

Clone the public flake:

```sh
nix-shell -p git --run 'git clone https://github.com/YOUR_USER/nix-flake.git /mnt/home/kane/nix-flake'
```

Regenerate the work host hardware configuration into the flake:

```sh
nixos-generate-config --root /mnt --show-hardware-config > /mnt/home/kane/nix-flake/nixos/hosts/work/hardware-configuration.nix
```

Before installing, inspect the generated hardware config:

```sh
less /mnt/home/kane/nix-flake/nixos/hosts/work/hardware-configuration.nix
```

Verify these points:

- fileSystems."/" points at the encrypted root filesystem or /dev/mapper/nixos-root.
- fileSystems."/boot" is ext4 and points at nixos-boot.
- fileSystems."/boot/efi" is vfat and points at the Windows EFI partition.
- boot.initrd.luks.devices exists if root was encrypted.
- fileSystems."/boot" is not vfat.

Install with flakes enabled:

```sh
export NIX_CONFIG="experimental-features = nix-command flakes"
nixos-install --flake /mnt/home/kane/nix-flake#work
```

Set the kane user password inside the installed system:

```sh
nixos-enter --root /mnt -c 'passwd kane'
```

Fix ownership of the cloned flake:

```sh
chown -R 1000:100 /mnt/home/kane/nix-flake
```

Reboot:

```sh
umount -R /mnt
reboot
```

First Boot Checks

After booting into NixOS:

```sh
findmnt / /boot /boot/efi /mnt/shared
sudo nixos-rebuild switch --flake ~/nix-flake#work
```

GRUB should show both NixOS and Windows. If the machine boots straight into Windows, check the firmware boot order and put the NixOS entry before Windows Boot Manager.

Boot Config

The work host intentionally uses GRUB, not systemd-boot:

```nix
boot.loader = {
  grub = {
    enable = true;
    configurationLimit = 5;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };

  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };
};
```

Shared Partition Mount

The work host mounts the Shared NTFS partition like this:

```nix
fileSystems."/mnt/shared" = {
  device = "/dev/disk/by-label/Shared";
  fsType = "ntfs3";
  options = [
    "rw"
    "uid=1000"
    "gid=100"
    "umask=022"
    "nofail"
    "windows_names"
  ];
};
```

Secrets And Public Repo Notes

- Do not commit VPN configs, keys, tokens, SSH keys, age keys, or .env files.
- The current OpenVPN config path points outside the repo at /mnt/shared/.secrets/OpenVPN/config/work.ovpn.
- If Shared is not encrypted, prefer moving VPN secrets onto the LUKS-encrypted NixOS root later and updating the config path.
- The flake itself is fine to make public as long as actual secret files are not included.

Important Rules

- Do not use systemd-boot for this work dual-boot setup.
- Do not store NixOS generations on the Windows EFI System Partition.
- Keep NixOS kernels/initrds on ext4 /boot.
- Use the shared NTFS partition for transfers and light shared data, not active Linux development.
- Prefer separate Git clones per OS for active development. Shared repos across Windows/Linux can cause line-ending, permissions, symlink, and case-sensitivity issues.

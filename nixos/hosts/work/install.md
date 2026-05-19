Recommended Layout
For a 512 GB SSD:
p1  EFI System Partition   1 GiB      FAT32      /boot/efi
p2  Microsoft Reserved     16 MiB     MSR        Windows-required
p3  Windows C:             180-220 GiB NTFS
p4  Shared Data            100-150 GiB NTFS
p5  NixOS /boot            2 GiB      ext4       /boot
p6  NixOS root             rest       btrfs/ext4/LUKS
Use NTFS for the shared partition. Windows supports it natively and NixOS can mount it reliably with the kernel ntfs3 driver. Avoid putting /home, /nix, or Linux-only dev environments there.
Install Order
1. Install Windows first.
2. Install NixOS second.
3. Let GRUB boot both.
Step-By-Step
1. Boot the Windows installer.
2. At disk selection, delete all existing partitions.
3. Create the Windows partition manually, e.g. 200 GB.
4. Let Windows create its EFI/MSR/recovery partitions.
5. Finish Windows install.
6. Boot Windows once.
7. Disable Fast Startup:
   - Control Panel → Power Options → Choose what power buttons do → disable Fast Startup.
8. If BitLocker is enabled, save the recovery key and suspend it before installing NixOS.
9. In Windows Disk Management, shrink/create space for:
   - shared partition
   - NixOS /boot
   - NixOS root
10. Create the shared partition in Windows as NTFS, give it a label like Shared.
11. Leave the NixOS space unformatted.
12. Boot the NixOS installer.
13. Create:
   - ext4 /boot, 2 GiB
   - NixOS root in remaining Linux space
14. Mount:
   - NixOS root at /mnt
   - Linux /boot at /mnt/boot
   - Windows ESP at /mnt/boot/efi
15. Install NixOS with GRUB, not systemd-boot.
NixOS Boot Config
Use roughly:
boot.loader.grub = {
  enable = true;
  configurationLimit = 5;
  efiSupport = true;
  device = "nodev";
  useOSProber = true;
  efiInstallAsRemovable = true;
};
boot.loader.efi = {
  canTouchEfiVariables = false;
  efiSysMountPoint = "/boot/efi";
};
This installs GRUB to the removable/fallback EFI path, which is more resilient if Windows resets EFI boot entries.
Shared Partition Mount
Example:
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
Important Rules
- Do not use systemd-boot for this setup.
- Do not store NixOS generations on the Windows ESP.
- Keep NixOS kernels/initrds on ext4 /boot.
- Use the shared NTFS partition for documents, installers, artifacts, and transfers.
- Prefer separate Git clones per OS for active development. Shared repos across Windows/Linux can cause line-ending, permissions, symlink, and case-sensitivity pain.

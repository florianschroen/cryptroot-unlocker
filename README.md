A simple Bash script to automatically unlock LUKS encrypted rootfs remote systems. Tested on Debian 10, probably also works for newer Ubuntu versions (18.04+).

The target system needs the package `dropbear` installed and configured (IP settings in `/etc/initramfs-tools/initramfs.conf` and `/etc/dropbear-initramfs/authorized_keys` with the key of the client, do not forget `update-initramfs -u`).

Rename `cryptroot-unlocker.conf.sample` to `cryptroot-unlocker.conf` and fill in hostname and LUKS key.

The script does its own check for the fingerprint so there are no problems running dropbear on the normal SSH port.

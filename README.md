Original script is from https://github.com/axldd/cryptroot-unlocker

# cryptroot-unlocker

A simple Bash script to automatically unlock LUKS encrypted rootfs remote systems. Tested on Debian 10, probably also works for newer Ubuntu versions (18.04+).

The target system needs the package `dropbear` installed and configured (IP settings in `/etc/initramfs-tools/initramfs.conf` and `/etc/dropbear-initramfs/authorized_keys` with the key of the client, do not forget `update-initramfs -u`).

Rename `cryptroot-unlocker.conf.sample` to `cryptroot-unlocker.conf` and fill in hostname and LUKS key.

The script does its own check for the fingerprint so there are no problems running dropbear on the normal SSH port.

## prepare authorized_keys

see references:
-  https://hamy.io/post/0005/remote-unlocking-of-luks-encrypted-root-in-ubuntu-debian/
-  https://hamy.io/post/0009/how-to-install-luks-encrypted-ubuntu-18.04.x-server-and-enable-remote-unlocking/

Put the key to `/etc/dropbear-initramfs/authorized_keys` at the server that should get unlocked.

```
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,command="/bin/cryptroot-unlock" ssh-rsa AA...vM= user@remote.server
```

..and run ` update-initramfs -u` to regenerate the initramfs.

## setup client "cron"

1. Deploy this script.
1. Update path to script in `homeserver-unlock.service`
1. Create Config. (`cp -v cryptroot-unlocker.conf.sample cryptroot-unlocker.conf`
1. Copy systemd service and timer to systemd config dir.

   When running **as user**:
   ```
   mkdir -p ~/.config/systemd/user
   cp -v homeserver-unlock.{service,timer} ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable homeserver-unlock.timer
   systemctl --user start homeserver-unlock.timer
   ```
   
   When running **as root/system**, use `/etc/systemd/system/` or `/lib/systemd/system/`.
   ```
   sudo cp -v homeserver-unlock.{service,timer} /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable homeserver-unlock.timer
   sudo systemctl start homeserver-unlock.timer
   ```
1. Test/Init/Add fingerprint to config:
   ```
   ./cryptroot-unlocker.sh
   ```

#!/bin/bash
# Shell script to make full backup of LXD
# This script considers LXD was installed via Snap
# This script considers ZFS as storage volume
# Based on https://www.cyberciti.biz/faq/how-to-backup-and-restore-lxd-containers/
# Author: Daniel M Brasil (github.com/danielmbrasil)

# Check if rsync is installed before starting
if [ ! -x /usr/bin/rsync ]; then
	echo "Rsync not installed. Please install it. Aborting." 
	exit 1
fi

# Backups root dir
BACKUPS_DIR="/backups"

# Checks if BACKUPS_DIR exists before creating it
if [ ! -d $BACKUPS_DIR ]; then
	mkdir -p "${BACKUPS_DIR}/lxd"
fi

# Today's date in yyyy-mm-dd format
NOW=$(date +'%Y-%m-%d')

# Dump LXD config
lxd init --dump > "${BACKUPS_DIR}/lxd/lxd.config.${NOW}"

# Dump all instaces list
lxc list > "${BACKUPS_DIR}/lxd/lxd.instances.list.${NOW}"

# Save LXD version
snap list lxd > "${BACKUPS_DIR}/lxd/lxd.version.${NOW}"

# Full backup of /var/snap/lxd/common/lxd using rsync
# First, checks if it's a firt time backup
# If so, run rsync using --sparse option
# Otherwise, use --partial option
if [ ! -d "${BACKUPS_DIR}/lxd/lxd-full-backup/" ]; then
	rsync --sparse -avrP /var/snap/lxd/common/lxd "${BACKUPS_DIR}/lxd/lxd-full-backup"
else
	rsync --partial -avrP /var/snap/lxd/common/lxd "${BACKUPS_DIR}/lxd/lxd-full-backup"
fi

# Backup all LXD instances with snapshots
for container in $(lxc list -c n --format csv)
do
	echo "Making bakcup of ${container}..."
	lxc export "${container}" "${BACKUPS_DIR}/lxd/${container}-${NOW}.tar.xz" --optimized-storage
done

# Tar full backup dir
tar -czvf "${BACKUPS_DIR}/lxd-backup-${NOW}.tar.xz" "${BACKUPS_DIR}/lxd"

#!/bin/bash
#
# env.sh -- edit uboot environment for prebuilt uboot images
#

ROOT_IMAGE=${U_ROOT_IMAGE}
DTB_IMAGE=${U_DTB_IMAGE}
KERNEL_IMAGE=${U_KERNEL_IMAGE}
BOOT_CMD=${U_BOOT_CMD}
IMAGES_DIR=${TFTPBOOT}
UBOOT_IMAGE=${BIMAGE}

# Save env to the last 1M of pflash
if [ -n "$ENV_IMG" ]; then
  [ ! -f $PFLASH_IMG ] && dd if=/dev/zero of=$PFLASH_IMG status=none bs=128K count=$((PFLASH_SIZE*8))
  dd if=$ENV_IMG of=$PFLASH_IMG bs=1M seek=$((PFLASH_SIZE-1)) conv=notrunc status=none
fi

# Ignore the old uggly method...
exit 0

if [ -f "$UBOOT_IMAGE" ]; then
  ## Fix up tftp server ip, only when the docker net is 10.66.33.n
  ## See /etc/default/docker: DOCKER_OPTS="$DOCKER_OPTS --bip=10.66.33.10/24"
  echo $ROUTE | grep -q 10.66.33
  if [ $? -eq 0 ]; then
    sed -i -e "s/route=[0-9.]* /route=$ROUTE /g" -ur $UBOOT_IMAGE
    sed -i -e "s/serverip [0-9.]*;/serverip $ROUTE;/g" -ur $UBOOT_IMAGE
  fi
  ## Fix up boot command
  sed -i -e "s/run bootcmd[0-9]*;/run $BOOT_CMD;/g" -ur $UBOOT_IMAGE
fi

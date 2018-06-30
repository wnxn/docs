# partition
## fdisk -l

## parted /dev/vdc

## mklabel gpt

## mkpart primary 0 -1

## print

# format
## mkfs.ext4 /dev/vdc

## mount /dev/vdc /mnt

## df -ah

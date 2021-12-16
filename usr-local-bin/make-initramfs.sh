#!/bin/busybox sh

[ -e ~/.config/make-initramfs.conf ] && source ~/.config/make-initramfs.conf

: ${INITRAMFS_DIR:=/usr/src/initramfs}
: ${INCLUDE_COMMANDS:=busybox cryptsetup}
: ${INCLUDE_EXTRA:=""}

E="$(echo -e '\e')"

BOLD="$E[1m"
RED="$E[31m"
GREEN="$E[32m"
NORMAL="$E[0m"

function errorshell() {
	if [ -n "$@" ]
	then
		echo
		echo "${BOLD}Error: $RED$@$NORMAL"
		echo
        echo "Usage:"
        echo
        echo "  $(basename "$0") [outfile.cpio.gz]"
        echo
		exit 1
	fi
}

[ "$(whoami)" == "root" ] || errorshell "Only root can do this (due to mknod). Try ${NORMAL}${BOLD}sudo $(basename $0) $@"

OUTFILE="$1"
shift

[ -n "$OUTFILE" ] || errorshell "No output file specified"

[ -n "$INITRAMFS_DIR" ] || errorshell "\$INITRAMFS_DIR cannot be empty!"

for C in $INCLUDE_COMMANDS
do
	INCLUDE_PATHS="${INCLUDE_PATHS:+${INCLUDE_PATHS} }$(which $C)"
done

INCLUDE_LIBS="$(ldd $INCLUDE_PATHS | sed -En 's!.*\s(/[^ ]+) \(.*!\1!p' | sort | uniq)"

# libgcc_s doesn't show up in ldd but cryptsetup needs it anyway
INCLUDE_LIBS="${INCLUDE_LIBS} $(LD_DEBUG=libs python3 -c "import ctypes; ctypes.CDLL('libgcc_s.so.1')" 2>&1 | egrep "trying file=.*libgcc_s.so.1$" | cut -d= -f2)"

echo "Initramfs projected size: $(du -cshH $INCLUDE_PATHS $INCLUDE_LIBS $INCLUDE_EXTRA | tail -n1)"

############################################
#
# Start building initramfs dir
#
###########################################

EXPECTED_FILES="dev/console dev/zero dev/null dev/tty init"

mkdir -p "$INITRAMFS_DIR" || errorshell "Can't create $INITRAMFS_DIR"

( cd "$INITRAMFS_DIR"; rm -f $EXPECTED_FILES; mkdir -p bin lib64 proc sys etc mnt dev dev/pts dev/shm; ) || errorshell "Failed to make base folders, eg bin,lib64,etc"

mknod -m 666 "$INITRAMFS_DIR/dev/null"    c 1 3 || errorshell "Could not create $INITRAMFS_DIR/dev/null"
mknod -m 666 "$INITRAMFS_DIR/dev/zero"    c 1 5 || errorshell "Could not create $INITRAMFS_DIR/dev/zero"
mknod -m 666 "$INITRAMFS_DIR/dev/tty"     c 5 0 || errorshell "Could not create $INITRAMFS_DIR/dev/tty"
mknod -m 600 "$INITRAMFS_DIR/dev/console" c 5 1 || errorshell "Could not create $INITRAMFS_DIR/dev/console"

ln -nfs /proc/mounts "$INITRAMFS_DIR/etc/mtab" || errorshell "Failed to prelink $INITRAMFS_DIR/etc/mtab"

for C in $INCLUDE_PATHS
do
	cp "$C" "$INITRAMFS_DIR/bin/" || errorshell "Could not copy $C to $INITRAMFS_DIR/bin/"
	EXPECTED_FILES="$EXPECTED_FILES bin/$(basename "$C")"
done

for L in $INCLUDE_LIBS
do
	cp "$L" "$INITRAMFS_DIR/lib64/" || errorshell "Could not copy $L to $INITRAMFS_DIR/lib64/"
	EXPECTED_FILES="$EXPECTED_FILES lib64/$(basename "$L")"
done

for E in $INCLUDE_EXTRA
do
	cp "$E" "$INITRAMFS_DIR/" || errorshell "Could not copy $E to $INITRAMFS_DIR/"
	EXPECTED_FILES="$EXPECTED_FILES $(basename "$E")"
done

###########################################
#
# Generate init script
#
###########################################

echo '#!/bin/busybox ash' > "$INITRAMFS_DIR/init"

if [ -f ~/.config/make-initramfs.conf ]
then
    cat ~/.config/make-initramfs.conf >> "$INITRAMFS_DIR/init"
fi

cat >> "$INITRAMFS_DIR/init" << 'ENDSCRIPT'

PATH="/bin:$PATH"

E="$(echo -e '\e')"

BOLD="$E[1m"
RED="$E[31m"
GREEN="$E[32m"
NORMAL="$E[0m"

function errorshell() {
	if [ -n "$@" ]
	then
		echo
		echo "${BOLD}Error: $RED$@$NORMAL"
		echo
		exec sh
	fi
}

mount -t proc     -o nodev,nosuid,noexec none /proc    || errorshell "Failed to mount /proc"
mount -t sysfs    -o nodev,nosuid,noexec none /sys     || errorshell "Failed to mount /sys"
mount -t devtmpfs -o nosuid,noexec       none /dev     || errorshell "Failed to mount /dev"
mount -t devpts   -o nosuid,noexec       none /dev/pts || errorshell "Failed to mount /dev/pts"
mount -t tmpfs    -o nodev,nosuid,noexec none /dev/shm || errorshell "Failed to mount /dev/shm"

mdev -s || errorshell "mdev -s Failed to populate /dev"

function getvar() {
    sed -En 's/(^|.* )'"$1"'=(\S+)( .*|$)/\2/ip; s/(^|.* )('"$1"')( .*|$)/\2/ip' /proc/cmdline
}

if [ -n "$(getvar luks)" ]
then
    LUKS="$(getvar luks)"
fi
if [ -n "$LUKS" ]
then
	echo "LUKS on $LUKS"
fi

if [ -n "$(getvar luksheader)" ]
then
    LUKSHEADER="$(getvar luksheader)"
fi

ROOT=/dev/mapper/root
if [ -n "$(getvar root)" ]
then
    ROOT="$(getvar root)"
fi

while ! cryptsetup open "$LUKS" "${LUKSHEADER:+--header $LUKSHEADER}" root
do
    echo "${BOLD}Error: ${RED}cryptsetup failed!$NORMAL"
    echo
    sleep 3
    echo -n "Try again? "
    read || errorshell "cryptsetup failed, user bailed!"
done

if [ -n "$(getvar rootfstype)" ]
then
    ROOTFSTYPE="$(getvar rootfstype)"
fi

if [ -n "$(getvar rootopts)" ]
then
    ROOTOPTS="$(getvar rootopts)"
fi

if [ -z "$(getvar rw)" ]
then
    ROOTOPTS="ro${ROOTOPTS:+,$ROOTOPTS}"
fi

mount ${ROOTOPTS:+-o $ROOTOPTS} ${ROOTFSTYPE:+-t $ROOTFSTYPE} "$ROOT" /mnt || errorshell "Failed to mount $ROOT ${ROOTFSTYPE:+($ROOTFSTYPE) }on /mnt"

umount /dev/pts
umount /dev/shm
umount /dev
umount /sys
umount /proc

switch_root /mnt /sbin/init || errorshell "Failed to switch_root"
ENDSCRIPT

chmod +x "$INITRAMFS_DIR/init"

( cd "$INITRAMFS_DIR"; find . -print0 | cpio --null --create --verbose --format=newc; ) | gzip --best > "$OUTFILE" || errorshell "Failed to generate $OUTFILE"

echo "$BOLD$GREEN$OUTFILE is ready$NORMAL"

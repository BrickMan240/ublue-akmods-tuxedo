#!/bin/sh

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

dnf install -y rpmdevtools rpm-build git tree
rpmdev-setuptree
git clone https://github.com/BrickMan240/tuxedo-drivers-kmod
cd tuxedo-drivers-kmod
./build.sh
cd ..
export TD_VERSION=$(cat tuxedo-drivers-kmod/tuxedo-drivers-kmod-common.spec | grep -E '^Version:' | awk '{print $2}')
rm -rf tuxedo-drivers-kmod/


### BUILD tuxedo-drivers (succeed or fail-fast with debug output)
dnf install -y \
    ~/rpmbuild/RPMS/x86_64/akmod-tuxedo-drivers-$TD_VERSION-1.$RELEASE.x86_64.rpm \
    ~/rpmbuild/RPMS/x86_64/tuxedo-drivers-kmod-common-$TD_VERSION-1.$RELEASE.x86_64.rpm \
    ~/rpmbuild/RPMS/x86_64/tuxedo-drivers-kmod-$TD_VERSION-1.$RELEASE.x86_64.rpm \
    ~/rpmbuild/RPMS/x86_64/kmod-tuxedo-drivers-$TD_VERSION-1.$RELEASE.x86_64.rpm
akmods --force --kernels "${KERNEL}" --kmod tuxedo-drivers-kmod
#modinfo /usr/lib/modules/${KERNEL}/extra/framework-laptop/framework_laptop.ko.xz > /dev/null \
#|| (find /var/cache/akmods/framework-laptop/ -name \*.log -print -exec cat {} \; && exit 1)

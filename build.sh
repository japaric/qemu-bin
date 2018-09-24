#!/bin/sh

set -euxo pipefail

main() {
    local uvers=$1 arch=$2 qvers=$3
    local gid=$(id -g) uid=$(id -u)

    curl -L https://download.qemu.org/qemu-$qvers.tar.xz | tar xJ

    pushd qemu-$qvers

    docker run --rm -v $(pwd):/pwd -w /pwd -it ubuntu:$uvers sh -c "
apt-get update
apt-get install -qq gcc libglib2.0-dev libpixman-1-dev make pkg-config python zlib1g-dev
useradd -m -u $uid alice
su alice -c './configure --disable-kvm --disable-vnc --enable-user --target-list=$arch-linux-user,$arch-softmmu'
su alice -c 'make -j$(nproc)'
"

    popd

    mkdir -p $uvers

    cp qemu-$qvers/arm-linux-user/qemu-arm $uvers/qemu-arm-$qvers
    cp qemu-$qvers/arm-softmmu/qemu-system-arm $uvers/qemu-system-arm-$qvers

    rm -rf qemu-$qvers
}

main "${@}"

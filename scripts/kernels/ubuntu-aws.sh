#! /bin/sh

REPO="brandonstevens/kernel-ubuntu-aws"
BASE_URL=http://mirrors.kernel.org/ubuntu/pool/main/l/linux-aws/

ARCH=amd64
LINKS=$(curl -s ${BASE_URL}/ | sed -n 's/.*href="\([^"]*\).*/\1/p')
# Just get names for 4.x kernels
KERNELS=$(echo $LINKS | \
    grep -o "linux-image-4\.[0-9]\+\.[0-9]\+-[0-9]\+-aws_[^ ]\+${ARCH}\.deb")

for KERN_DEB in $KERNELS; do
    VERSION=$(echo $KERN_DEB | \
        grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+-[0-9]\+" | head -1)

    echo "$VERSION -> $KERN_DEB"
    DOCKER_CONTENT_TRUST=1 docker pull ${REPO}:${VERSION} && continue

    # extra doesn't exist
    # EXTRA_DEB=$(echo $LINKS | \
    #     grep -o "linux-image-extra-${VERSION}-generic_[^ ]\+${ARCH}\.deb")

    # Don't pull in the headers. This is mostly for testing
    # HDR_DEB=$(echo $LINKS | \
    #     grep -o "linux-headers-${VERSION}_[^ ]\+_all\.deb")
    # HDR_ARCH_DEB=$(echo $LINKS | \
    #     grep -o "linux-headers-${VERSION}-generic_[^ ]\+_${ARCH}\.deb")

    URLS="${BASE_URL}/${KERN_DEB}"

    # Doesn't exist build and push
    docker build -t ${REPO}:${VERSION} -f Dockerfile.deb --no-cache \
           --build-arg DEB_URLS="${URLS}" . &&
        DOCKER_CONTENT_TRUST=1 docker push ${REPO}:${VERSION}
done

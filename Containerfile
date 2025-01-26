FROM --platform=linux/arm64 registry.fedoraproject.org/fedora:42 as builder
RUN dnf install -y rpm-build git dnf-plugins-core
WORKDIR /usr/src/rootfiles
RUN git clone https://src.fedoraproject.org/rpms/rootfiles.git .
RUN git fetch origin +refs/pull/*:refs/remotes/origin/pr/*
RUN git checkout origin/pr/5/head
RUN dnf builddep -y rootfiles.spec
RUN rpmbuild -bb rootfiles.spec \
    --define "_topdir `pwd`" \
    --define "_sourcedir `pwd`" \
    --define "_specdir `pwd`" \
    --define "_builddir `pwd`" \
    --define "_srcrpmdir `pwd`" \
    --define "_rpmdir `pwd`"


FROM --platform=linux/arm64 quay.io/fedora/fedora-bootc:42
WORKDIR /tmp
COPY --from=builder /usr/src/rootfiles/noarch/rootfiles-*.rpm .
RUN dnf -y install rootfiles-*.rpm
RUN dnf -y install git \
                   bash \
                   nano \
                   curl \
                   fish \
                   podman \
                   ruby \
                   fedora-iot-config \
                   fedora-release-iot

# Set fish as the default shell for the container
RUN echo "/usr/bin/fish" >> /etc/shells && \
    chsh -s /usr/bin/fish

# Fix /root if it's a symlink or invalid
RUN rm -rf /root && mkdir -p /root && chmod 755 /root

# Remove dangling symlink and recreate /home
RUN rm -f /home && mkdir -p /home && chmod 755 /home

# Install Linuxbrew
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ZhongRuoyu/homebrew-aarch64-linux/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

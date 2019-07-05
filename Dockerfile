FROM lnls/epics-dist:base-3.15-synapps-lnls-R1-2-1-debian-9.5 as builder

ENV IOC_REPO mtca-ipmi-epics-ioc
ENV COMMIT v1.0.1

# Clone Our IOC for later usage. Let's just get rid of the
# private SSH key as soon as possible. We will not build the IOC
# just yet.
ARG SSH_PRIVATE_KEY

RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && \
    chmod 700 /root/.ssh/id_rsa && \
    chown -R root:root /root/.ssh

# MTCA IPMI
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    ssh-keyscan -t rsa gitlab.cnpem.br > ~/.ssh/known_hosts && \
    git clone git@gitlab.cnpem.br:DIG/${IOC_REPO}.git /opt/epics/${IOC_REPO} && \
    cd /opt/epics/${IOC_REPO} && \
    git checkout ${COMMIT} && \
    echo 'EPICS_BASE=/opt/epics/base' > configure/RELEASE.local && \
    echo 'PYDEVSUP=/opt/epics/${PY_DEVSUP}' >> configure/RELEASE.local && \
    echo 'IPMITOOL=/usr/local/bin' >> configure/RELEASE.local

# Copy only repo to our new image not our SSH private key
FROM lnls/epics-dist:base-3.15-synapps-lnls-R1-2-1-debian-9.5
# copy the repository form the previous image
COPY --from=builder /opt/epics/${IOC_REPO} /opt/epics/${IOC_REPO}

ENV IOC_REPO mtca-ipmi-epics-ioc
ENV BOOT_DIR  iocMTCAIpmi

ENV PY_DEVSUP pyDevSup
ENV PY_DEVSUP_COMMIT master

ENV IPMITOOL_VERSION 1.8.11

ENV PYTHON=python3.5
ENV PY_VER=3.5

# For PyDevSup
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    apt-get update && \
    apt-get install -y \
        python3-dev \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

# PyDevSup
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    git clone https://github.com/mdavidsaver/${PY_DEVSUP} /opt/epics/${PY_DEVSUP} && \
    cd /opt/epics/${PY_DEVSUP} && \
    git checkout ${PY_DEVSUP_COMMIT} && \
    pip3 install -r requirements-deb9.txt && \
    echo 'EPICS_BASE=/opt/epics/base' > configure/RELEASE.local && \
    echo 'SUPPORT=/opt/epics/synApps-lnls-R1-2-1/support' >> configure/RELEASE.local && \
    echo 'AUTOSAVE=$(SUPPORT)/autosave-R5-9' >> configure/RELEASE.local && \
    echo 'DEVIOCSTATS=$(SUPPORT)/iocStats-3-1-15' >> configure/RELEASE.local && \
    make && \
    make install

# For IPMITOOL
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    apt-get update && \
    apt-get install -y \
        wget \
        libncurses5-dev \
        libreadline-dev \
        gnome-terminal && \
    rm -rf /var/lib/apt/lists/*

# IPMITOOL
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    wget https://sourceforge.net/projects/ipmitool/files/ipmitool/${IPMITOOL_VERSION}/ipmitool-${IPMITOOL_VERSION}.tar.bz2 && \
    tar xvf ipmitool-${IPMITOOL_VERSION}.tar.bz2 && \
    cd ipmitool-${IPMITOOL_VERSION} && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf ipmitool-${IPMITOOL_VERSION}.tar.bz2 && \
    rm -rf ipmitool-${IPMITOOL_VERSION}

# For MTCA IPMI
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    pip3 install \
        numpy \
        subprocess32

# MTCA IPMI
RUN cd /opt/epics/${IOC_REPO} && \
    make && \
    make install

# Source environment variables until we figure it out
# where to put system-wide env-vars on docker-debian
RUN . /root/.bashrc

WORKDIR /opt/epics/startup/ioc/${IOC_REPO}/iocBoot/${BOOT_DIR}

ENTRYPOINT ["./runProcServ.sh"]

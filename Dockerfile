FROM lnls/epics-dist:base-3.15-synapps-lnls-R1-2-1-debian-9.5

ENV IOC_REPO mtca-ipmi-epics-ioc
ENV BOOT_DIR  iocMTCAIpmi
ENV COMMIT v1.1.0

ENV PY_DEVSUP pyDevSup
ENV PY_DEVSUP_COMMIT master

ENV IPMITOOL_VERSION 1.8.18

ENV PYTHON=python3.5
ENV PY_VER=3.5

# MTCA IPMI
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf && \
    git clone https://github.com/lnls-dig/${IOC_REPO} /opt/epics/${IOC_REPO} && \
    cd /opt/epics/${IOC_REPO} && \
    git checkout ${COMMIT} && \
    echo 'EPICS_BASE=/opt/epics/base' > configure/RELEASE.local && \
    echo 'PYDEVSUP=/opt/epics/${PY_DEVSUP}' >> configure/RELEASE.local && \
    echo 'IPMITOOL=/usr/local/bin' >> configure/RELEASE.local

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

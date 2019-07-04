#!/usr/bin/env bash

set -u

if [ -z "$MTCA_IPMI_INSTANCE" ]; then
    echo "MTCA_IPMI_INSTANCE environment variable is not set." >&2
    exit 1
fi

/usr/bin/docker stop \
    mtca-ipmi-epics-ioc-${MTCA_IPMI_INSTANCE}

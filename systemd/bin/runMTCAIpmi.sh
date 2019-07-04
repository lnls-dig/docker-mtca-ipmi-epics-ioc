#!/usr/bin/env bash

set -u

if [ -z "$MTCA_IPMI_INSTANCE" ]; then
    echo "MTCA_IPMI_INSTANCE environment variable is not set." >&2
    exit 1
fi

export MTCA_IPMI_CURRENT_PV_AREA_PREFIX=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_PV_AREA_PREFIX
export MTCA_IPMI_CURRENT_PV_DEVICE_PREFIX=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_PV_DEVICE_PREFIX
export MTCA_IPMI_CURRENT_DEVICE_IP=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_DEVICE_IP
export MTCA_IPMI_CURRENT_TELNET_PORT=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_TELNET_PORT
export MTCA_IPMI_CURRENT_CRATE_ID=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_CRATE_ID
export MTCA_IPMI_CURRENT_RACK_ID=MTCA_IPMI_${MTCA_IPMI_INSTANCE}_RACK_ID
# Only works with bash
export MTCA_IPMI_PV_AREA_PREFIX=${!MTCA_IPMI_CURRENT_PV_AREA_PREFIX}
export MTCA_IPMI_PV_DEVICE_PREFIX=${!MTCA_IPMI_CURRENT_PV_DEVICE_PREFIX}
export MTCA_IPMI_DEVICE_IP=${!MTCA_IPMI_CURRENT_DEVICE_IP}
export MTCA_IPMI_TELNET_PORT=${!MTCA_IPMI_CURRENT_TELNET_PORT}
export MTCA_IPMI_CRATE_ID=${!MTCA_IPMI_CURRENT_CRATE_ID}
export MTCA_IPMI_RACK_ID=${!MTCA_IPMI_CURRENT_RACK_ID}

# Create volume for autosave and ignore errors
/usr/bin/docker create \
    -v /opt/epics/startup/ioc/mtca-ipmi-epics-ioc/iocBoot/iocMTCAIpmi/autosave \
    --name mtca-ipmi-epics-ioc-${MTCA_IPMI_INSTANCE}-volume \
    lnlsdig/mtca-ipmi-epics-ioc:${IMAGE_VERSION} \
    2>/dev/null || true

# Remove a possible old and stopped container with
# the same name
/usr/bin/docker rm \
    mtca-ipmi-epics-ioc-${MTCA_IPMI_INSTANCE} || true

/usr/bin/docker run \
    --net host \
    -t \
    --rm \
    --volumes-from mtca-ipmi-epics-ioc-${MTCA_IPMI_INSTANCE}-volume \
    --name mtca-ipmi-epics-ioc-${MTCA_IPMI_INSTANCE} \
    lnlsdig/mtca-ipmi-epics-ioc:${IMAGE_VERSION} \
    -t "${MTCA_IPMI_DEVICE_TELNET_PORT}" \
    -i "${MTCA_IPMI_DEVICE_IP}" \
    -P "${MTCA_IPMI_PV_AREA_PREFIX}" \
    -R "${MTCA_IPMI_PV_DEVICE_PREFIX}" \
    -c "${MTCA_IPMI_CRATE_ID}" \
    -r "${MTCA_IPMI_RACK_ID}" \
    -d "${MTCA_IPMI_INSTANCE}"

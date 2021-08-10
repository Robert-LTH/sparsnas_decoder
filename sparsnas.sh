#!/bin/zsh

# simplified

export RTL_SDR=(/usr/bin/rtl_sdr -f 868000000 -s 1024000 -g 40 -)
export SPARSNAS_DECODE=/usr/bin/sparsnas_decode
if [ ! -f /tmp/${SPARSNAS_SENSOR_ID}.freq ]; then
 busybox timeout 45 $RTL_SDR > /tmp/sparsnas.raw
 $SPARSNAS_DECODE /tmp/sparsnas.raw --find-frequencies > /tmp/${SPARSNAS_SENSOR_ID}.freq
fi
export SPARSNAS_FREQ_MIN=\`awk -F= '/MIN/ {print \$2}' < /tmp/${SPARSNAS_SENSOR_ID}.freq\`
export SPARSNAS_FREQ_MAX=\`awk -F= '/MAX/ {print \$2}' < /tmp/${SPARSNAS_SENSOR_ID}.freq\`
`$RTL_SDR | $SPARSNAS_DECODE`

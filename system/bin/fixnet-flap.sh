#!/bin/bash
# Flap a network interface after a short delay, giving the USB-C ethernet
# adapter time to attempt (and fail) autonegotiation before we reset it -
# flapping immediately on device creation is too early to help.
iface="$1"
sleep 3
/usr/bin/ip link set "$iface" down
sleep 1
/usr/bin/ip link set "$iface" up

#!/bin/bash

if ip link show enp0s3 | grep -q "state UP"; then
    echo ""
else
    echo "No internet"
fi

#!/bin/bash

if ip link show | grep -q "state UP"; then
    echo ""
else
    echo "No internet"
fi

#!/bin/bash

if ! ip link show | grep -q "state UP"; then
    echo "No internet"
fi

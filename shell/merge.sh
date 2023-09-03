#!/bin/bash

# File paths
textdoc1="/home/$(whoami)/sysZ/conf/i3"
textdoc2="/home/$(whoami)/.config/i3/config"

# Find the line number of the "=============================" line in TextDoc2.txt
delimiter_line_number=$(grep -n "#=====EDIT_UNDER_THIS_LINE=====" "$textdoc2" | cut -d ':' -f 1)

# If the delimiter is found, proceed with the replacement
if [ -n "$delimiter_line_number" ]; then
    # Extract everything under the delimiter from TextDoc2.txt
    tail -n +"$delimiter_line_number" "$textdoc2" >temp.txt

    # Prepend the content of TextDoc1.txt to temp.txt
    cat "$textdoc1" temp.txt >updated_temp.txt

    # Overwrite TextDoc2.txt with the updated content
    mv updated_temp.txt "$textdoc2"
else
    echo "Delimiter not found in $textdoc2"
fi

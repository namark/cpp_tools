#!/bin/sh
allinclude $1 | grep creating | sed 's/creating: //' | xargs -I{} sort -o {} {}

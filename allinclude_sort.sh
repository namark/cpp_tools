#!/bin/sh
allinclude "$@" | grep creating | sed 's/creating: //' | xargs -I{} sort -o {} {}

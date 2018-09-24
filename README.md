# cpp_tools
Here I collect tools I wrote for managing my c++ projects.

### allinclude.cpp
For each subdirectory in provided(or current) directory generates an .hpp file with the same name that includes all .h[pp] files in that subdirectory, then does the same recursively for each of those subdirectiry.

### allinclude_sort.sh
Wrapper for allinclude, that just uses sort command to sort the includes in generated hpp files.

# cpp_tools
Here I collect tools I wrote for managing my c++ projects.

### allinclude.cpp
For each subdirectory in provided(or current) directory generates an .hpp file with the same name that includes all .h[pp] files in that subdirectory, then does the same recursively for each of those subdirectories.

### allinclude_sort.sh
Wrapper for allinclude, that just uses sort command to sort the includes in generated hpp files.

### make_templates
As the name suggests - some Makefile templates. The filenames of individual templates are pretty self explanatory as well. They are ugly from inside though and probably break some conventions.

#!/bin/sh

#=======================================================================
#   Copyright (C) 2025 Univ. of Bham  All rights reserved.
#   
#   		FileName：		compile.sh
#   	 	Author：		LongLI <long.l@cern.ch>
#   		Time：			2025.04.03
#   		Description：
#
#======================================================================

rm -rf build
cmake -S . -B build -DAllpix_DIR=/usr/local/share/allpix2/share/cmake/
cmake --build build
source build/setup.sh

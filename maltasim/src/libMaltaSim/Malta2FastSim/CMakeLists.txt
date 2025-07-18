# SPDX-FileCopyrightText: 2017-2024 CERN and the Allpix Squared authors
# SPDX-License-Identifier: MIT
FIND_PACKAGE(Allpix 3.1 REQUIRED) 
# Define module and return the generated name as MODULE_NAME
ALLPIX_DETECTOR_MODULE(MODULE_NAME)

# Add source files to library
ALLPIX_MODULE_SOURCES(${MODULE_NAME} Malta2FastSimModule.cpp)

FILE(APPEND ${CMAKE_BINARY_DIR}/setup.sh
    "export LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:$LD_LIBRARY_PATH\n"
  	)

#
# Prepare a setup script
file(WRITE ${CMAKE_BINARY_DIR}/setup.sh
    "echo 'Setting up your MALTA simulation environment.'\n"
)

#
# Add libraries
add_subdirectory(libMaltaSim)
add_subdirectory(libMaltaAllPix2)


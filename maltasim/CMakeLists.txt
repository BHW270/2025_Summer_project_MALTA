cmake_minimum_required (VERSION 3.15)

project(maltasim
  DESCRIPTION "Library for simulating the MALTA family of chips.")

# The version number.
set(maltasim_VERSION_MAJOR 0)
set(maltasim_VERSION_MINOR 0)
set(maltasim_VERSION_PATCH 1)

# Source code
add_subdirectory(src)

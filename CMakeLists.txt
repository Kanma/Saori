cmake_minimum_required(VERSION 2.6)
project(SAORI)

# Set the output paths
if (NOT DEFINED ATHENA_BINARY_DIR)
    set(ATHENA_BINARY_DIR "${SAORI_BINARY_DIR}")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${SAORI_BINARY_DIR}/bin")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${SAORI_BINARY_DIR}/lib")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${SAORI_BINARY_DIR}/bin")
endif()

# Set the dependencies path
if (NOT DEFINED ATHENA_DEPENDENCIES_DIR)
    set(ATHENA_DEPENDENCIES_DIR "${SAORI_SOURCE_DIR}/dependencies")
endif()

# We only support Intel 32bits builds
if (APPLE)
    set(CMAKE_OSX_ARCHITECTURES "i386" CACHE INTERNAL "" FORCE)
    set(CMAKE_OSX_ARCHITECTURES_DEFAULT "ppc" CACHE INTERNAL "" FORCE)
endif()

# Setup the dependencies
set(ATHENA_MATH_STATIC ON)
set(ATHENA_CORE_STATIC ON)
set(ATHENA_ENTITIES_STATIC ON)
set(ATHENA_GRAPHICS_STATIC ON)
set(ATHENA_PHYSICS_STATIC ON)
set(ATHENA_INPUTS_STATIC ON)
set(ATHENA_FRAMEWORK_USE_DEFAULT_CONFIGURATION OFF)
set(OGRE_BUILD_PLUGIN_BSP FALSE)
set(OGRE_BUILD_PLUGIN_OCTREE TRUE)
set(OGRE_BUILD_PLUGIN_PCZ FALSE)
set(OGRE_BUILD_PLUGIN_PFX TRUE)
set(OGRE_BUILD_PLUGIN_CG TRUE)

# Import XMake
if (NOT EXISTS "${ATHENA_DEPENDENCIES_DIR}/xmake/XMake.cmake")
    message(FATAL_ERROR
"Missing dependency: XMake
Saori requires the following dependencies:
   - XMake
   - Athena-Math
   - Athena-Core
   - Athena-Entities
   - Athena-Graphics
   - Athena-Physics
   - Athena-Inputs
   - Athena-Framework
   - UnitTest++
   - Ogre
   - Bullet
   - FreeImage
   - FreeType
   - ZLib
   - zziplib
They are provided as GIT submodules of this repository.
Did you forgot to execute the following commands?
   git submodule init
   git submodule update")
endif()

include("${ATHENA_DEPENDENCIES_DIR}/xmake/XMake.cmake")

# Process the dependencies
add_subdirectory(dependencies)

# Subdirectories to process
add_subdirectory(src)
add_subdirectory(config)

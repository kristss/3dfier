cmake_minimum_required(VERSION 3.5)
project( 3dfier )

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/" ${CMAKE_MODULE_PATH})

set( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true )

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
endif()

set(THREEDFIER_DEV_OPT_LEVEL "2" CACHE STRING "Optimization level for RelWithDebInfo builds (1 or 2)")
set_property(CACHE THREEDFIER_DEV_OPT_LEVEL PROPERTY STRINGS 1 2)
if(NOT THREEDFIER_DEV_OPT_LEVEL MATCHES "^[12]$")
  message(FATAL_ERROR "THREEDFIER_DEV_OPT_LEVEL must be either 1 or 2.")
endif()
 
if ( COMMAND cmake_policy )
  cmake_policy( SET CMP0003 NEW )  
endif()

# Boost
find_package( Boost REQUIRED locale chrono system filesystem program_options )

# GDAL
find_package( GDAL REQUIRED )

# LASLIB
find_package( LASlib REQUIRED )

# YamlCpp
find_package( yaml-cpp REQUIRED )

# CGAL
find_package( CGAL REQUIRED QUIET COMPONENTS )

# include helper file
include( ${CGAL_USE_FILE} )

if(MSVC)
  add_definitions(-DNOMINMAX)
  add_definitions("/EHsc")
endif()

include_directories( ${CMAKE_SOURCE_DIR}/thirdparty )

include_directories( ${CGAL_INCLUDE_DIR} ${CGAL_3RD_PARTY_INCLUDE_DIR} ${Boost_INCLUDE_DIRS} ${YAML_CPP_INCLUDE_DIR} ${GDAL_INCLUDE_DIR})

# # build ptinpoly as static lib
# add_library(ptinpoly STATIC thirdparty/ptinpoly.c)
# set_target_properties(
#   ptinpoly
#   PROPERTIES C_STANDARD 11
# )

# Creating entries for target: 3dfier
FILE(GLOB SRC_FILES src/*.cpp)
add_executable(3dfier ${SRC_FILES})
set_target_properties(
  3dfier
  PROPERTIES CXX_STANDARD 11
)

target_link_libraries( 3dfier ${CGAL_LIBRARIES} ${CGAL_3RD_PARTY_LIBRARIES} ${GDAL_LIBRARY} yaml-cpp Boost::program_options Boost::filesystem Boost::locale Boost::chrono LASlib)

target_compile_options(3dfier PRIVATE
  $<$<AND:$<CONFIG:RelWithDebInfo>,$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>>>:-O${THREEDFIER_DEV_OPT_LEVEL}>
)

install(TARGETS 3dfier DESTINATION bin)

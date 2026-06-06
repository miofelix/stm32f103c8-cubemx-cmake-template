cmake_minimum_required(VERSION 3.25)

#
# This file is generated only once,
# and is not re-generated if converter is called multiple times.
#
# User is free to modify the file as much as necessary
#

# Setup compiler settings
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)


# Define the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Set the project name
set(CMAKE_PROJECT_NAME stm32f103_project)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${CMAKE_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME})

# Add STM32CubeMX generated sources
add_subdirectory(cmake/stm32cubemx)

# --- Batteries-included HAL --------------------------------------------------
# cmake/stm32cubemx/CMakeLists.txt (CubeMX-regenerated) only compiles the driver
# sources for peripherals enabled in the .ioc. To let any F103C8 peripheral build
# without re-running CubeMX just to add a driver file, swap that curated subset
# on the STM32_Drivers target for every source under Drivers/.../Src. Module
# selection remains in Core/Inc/stm32f1xx_hal_conf.h, matching the STM32 HAL
# project convention. Disabled modules compile to nothing, and unused code is
# dropped at link time by -ffunction-sections/-fdata-sections + --gc-sections.
get_target_property(_mx_driver_src STM32_Drivers SOURCES)
list(FILTER _mx_driver_src EXCLUDE REGEX "/Drivers/STM32F1xx_HAL_Driver/Src/")
file(GLOB _hal_full_src CONFIGURE_DEPENDS
    ${CMAKE_SOURCE_DIR}/Drivers/STM32F1xx_HAL_Driver/Src/*.c)
set_property(TARGET STM32_Drivers PROPERTY SOURCES ${_mx_driver_src} ${_hal_full_src})
# -----------------------------------------------------------------------------

# Enable HAL parameter checking (assert_param) in Debug builds only. Applied to
# the shared interface target so it reaches BOTH application and driver sources;
# assert_failed() is implemented in Core/Src/main.c.
target_compile_definitions(stm32cubemx INTERFACE $<$<CONFIG:Debug>:USE_FULL_ASSERT>)

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined library search paths
)

# Add sources to executable
target_sources(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user sources here
)

# Add include paths
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined include paths
)

# Add project symbols (macros)
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined symbols
)

# Remove wrong libob.a library dependency when using cpp files
list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_LIBRARIES ob)

# Add linked libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    stm32cubemx

    # Add user defined libraries
)

include(cmake/firmware-images.cmake)
include(cmake/flash-targets.cmake)

add_firmware_images(${CMAKE_PROJECT_NAME})
add_openocd_flash_targets(${CMAKE_PROJECT_NAME})

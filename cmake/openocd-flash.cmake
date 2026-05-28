if(NOT DEFINED OPENOCD_EXECUTABLE)
    message(FATAL_ERROR "OPENOCD_EXECUTABLE is not set")
endif()

if(NOT DEFINED PROJECT_ELF)
    message(FATAL_ERROR "PROJECT_ELF is not set")
endif()

if(NOT DEFINED ACTION)
    message(FATAL_ERROR "ACTION is not set")
endif()

set(FLASH_ADAPTER "$ENV{FLASH_ADAPTER}")
if(FLASH_ADAPTER STREQUAL "")
    set(FLASH_ADAPTER "stlink")
endif()
string(TOLOWER "${FLASH_ADAPTER}" FLASH_ADAPTER)

set(OPENOCD_TARGET "$ENV{OPENOCD_TARGET}")
if(OPENOCD_TARGET STREQUAL "")
    set(OPENOCD_TARGET "target/stm32f1x.cfg")
endif()

if(FLASH_ADAPTER STREQUAL "stlink")
    set(OPENOCD_INTERFACE "interface/stlink.cfg")
    set(FLASH_ADAPTER_NAME "ST-LINK")
elseif(FLASH_ADAPTER STREQUAL "daplink")
    set(OPENOCD_INTERFACE "interface/cmsis-dap.cfg")
    set(FLASH_ADAPTER_NAME "DAPLink/CMSIS-DAP")
else()
    message(FATAL_ERROR "Unsupported FLASH_ADAPTER: ${FLASH_ADAPTER}. Use stlink or daplink.")
endif()

if(ACTION STREQUAL "flash")
    set(OPENOCD_COMMAND "program ${PROJECT_ELF} verify reset exit")
elseif(ACTION STREQUAL "erase")
    set(OPENOCD_COMMAND "init; reset halt; stm32f1x mass_erase 0; reset run; shutdown")
elseif(ACTION STREQUAL "reset")
    set(OPENOCD_COMMAND "init; reset run; shutdown")
else()
    message(FATAL_ERROR "Unsupported ACTION: ${ACTION}. Use flash, erase or reset.")
endif()

message(STATUS "Using ${FLASH_ADAPTER_NAME}: ${OPENOCD_INTERFACE}")

execute_process(
    COMMAND "${OPENOCD_EXECUTABLE}"
        -f "${OPENOCD_INTERFACE}"
        -f "${OPENOCD_TARGET}"
        -c "${OPENOCD_COMMAND}"
    RESULT_VARIABLE OPENOCD_RESULT
)

if(NOT OPENOCD_RESULT EQUAL 0)
    message(FATAL_ERROR "OpenOCD command failed with exit code ${OPENOCD_RESULT}")
endif()

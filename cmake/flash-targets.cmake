function(add_openocd_flash_targets TARGET_NAME)
    find_program(OPENOCD_EXECUTABLE openocd)

    if(NOT OPENOCD_EXECUTABLE)
        message(STATUS "OpenOCD not found; flash, erase and reset targets are unavailable")
        return()
    endif()

    set(OPENOCD_SCRIPT "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/openocd-flash.cmake")

    add_custom_target(flash
        COMMAND ${CMAKE_COMMAND}
            "-DOPENOCD_EXECUTABLE:FILEPATH=${OPENOCD_EXECUTABLE}"
            "-DPROJECT_ELF:FILEPATH=$<TARGET_FILE:${TARGET_NAME}>"
            "-DACTION=flash"
            -P "${OPENOCD_SCRIPT}"
        DEPENDS ${TARGET_NAME}
        USES_TERMINAL
        COMMENT "Flashing ${TARGET_NAME}.elf"
    )

    add_custom_target(erase
        COMMAND ${CMAKE_COMMAND}
            "-DOPENOCD_EXECUTABLE:FILEPATH=${OPENOCD_EXECUTABLE}"
            "-DPROJECT_ELF:FILEPATH=$<TARGET_FILE:${TARGET_NAME}>"
            "-DACTION=erase"
            -P "${OPENOCD_SCRIPT}"
        USES_TERMINAL
        COMMENT "Erasing STM32 flash"
    )

    add_custom_target(reset
        COMMAND ${CMAKE_COMMAND}
            "-DOPENOCD_EXECUTABLE:FILEPATH=${OPENOCD_EXECUTABLE}"
            "-DPROJECT_ELF:FILEPATH=$<TARGET_FILE:${TARGET_NAME}>"
            "-DACTION=reset"
            -P "${OPENOCD_SCRIPT}"
        USES_TERMINAL
        COMMENT "Resetting target"
    )
endfunction()

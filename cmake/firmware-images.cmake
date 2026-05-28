function(add_firmware_images TARGET_NAME)
    if(NOT CMAKE_OBJCOPY)
        message(FATAL_ERROR "CMAKE_OBJCOPY is not set; check the toolchain file")
    endif()

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex
            $<TARGET_FILE:${TARGET_NAME}>
            $<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}.hex
        COMMAND ${CMAKE_OBJCOPY} -O binary
            $<TARGET_FILE:${TARGET_NAME}>
            $<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}.bin
        COMMENT "Generating ${TARGET_NAME}.hex and ${TARGET_NAME}.bin"
    )
endfunction()

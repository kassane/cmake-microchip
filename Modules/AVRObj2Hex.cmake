#=============================================================================
# Copyright 2016 Sam Hanes
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file COPYING.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake-Microchip,
#  substitute the full License text for the above reference.)


function(avr_obj2hex target)
    find_program(AVR_OBJ2HEX
        NAMES ${_CMAKE_TOOLCHAIN_PREFIX}avr-objcopy avr-objcopy
        HINTS ${_CMAKE_TOOLCHAIN_LOCATION}
    )

    if(NOT AVR_OBJ2HEX)
        message(SEND_ERROR "No avr-objcopy program was found")
    endif()

    function(get_target_property_fallback var target)
        set(result NOTFOUND)
        foreach(property ${ARGN})
            get_target_property(result ${target} ${property})
            if(result)
                break()
            endif()
        endforeach()
        set(${var} ${result} PARENT_SCOPE)
    endfunction()

    get_target_property_fallback(in_f ${target}
        RUNTIME_OUTPUT_NAME
        OUTPUT_NAME
        NAME
    )

    get_target_property_fallback(dir ${target}
        RUNTIME_OUTPUT_DIRECTORY
        BINARY_DIR
    )

    get_filename_component(out_f ${in_f} NAME_WE)
    set(out_f "${out_f}$<$<CONFIG:DEBUG>:${CMAKE_DEBUG_POSTFIX}>.hex")

    add_custom_command(
        TARGET ${target} POST_BUILD
        WORKING_DIRECTORY ${dir}/$<CONFIG>
        COMMAND "${AVR_OBJ2HEX}" -O ihex "${in_f}$<$<CONFIG:DEBUG>:${CMAKE_DEBUG_POSTFIX}>.elf" "${out_f}"
        BYPRODUCTS ${dir}/$<CONFIG>/${out_f}
        VERBATIM
    )

    set_property(DIRECTORY APPEND
        PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
            ${dir}/$<CONFIG>/${out_f}
    )
    
    install(FILES ${dir}/$<CONFIG>/${out_f} TYPE BIN)
endfunction()

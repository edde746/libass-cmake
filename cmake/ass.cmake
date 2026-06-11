cmake_minimum_required(VERSION 3.10)
# libass ships hand-written asm only for x86/x86_64/aarch64; forcing
# --enable-asm on armeabi-v7a would fail configure. ARM32 relies on the
# NEON compiler flags set in the parent CMakeLists instead.
if(ANDROID_ABI STREQUAL "armeabi-v7a")
    set(ASS_ASM_ARG "")
else()
    set(ASS_ASM_ARG "--enable-asm")
endif()
ExternalProject_Add(ep_ass
    DEPENDS ep_fontconfig ep_harfbuzz ep_freetype ep_fribidi ep_unibreak
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
    SOURCE_SUBDIR "src/ass"
    INSTALL_DIR ${CMAKE_BINARY_DIR}
    CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -E env ${PLATFORM_CONFIGURE_ENV}
        <SOURCE_DIR>/<SOURCE_SUBDIR>/configure
        ${PLATFORM_BUILD_AND_HOST} ${CONFIGURE_VERBOSE_ARG}
        --prefix=<INSTALL_DIR>
        --enable-static
        --disable-shared
        --enable-fontconfig
        --enable-libunibreak
        # Fail the build instead of silently falling back to scalar C when the
        # cross toolchain can't assemble libass's aarch64/x86 ASM (blur/blend
        # hot paths are 5-20x slower without it). Empty on armeabi-v7a.
        ${ASS_ASM_ARG}
        --srcdir=<SOURCE_DIR>/<SOURCE_SUBDIR>
    BUILD_COMMAND make
    INSTALL_COMMAND make install
)
add_dependencies(ep_ass ep_freetype ep_harfbuzz ep_fribidi ep_unibreak)
include_directories({CMAKE_BINARY_DIR}/include)
link_directories({CMAKE_BINARY_DIR}/lib)
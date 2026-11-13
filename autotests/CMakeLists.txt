# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Jakob Petsovits <jpetso@petsovits.com>

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Test)

add_executable(safemodebackupcategories_test
    safemodebackupcategories_test.cpp
    ${CMAKE_SOURCE_DIR}/src/safemodebackupcategories.cpp
)
target_include_directories(safemodebackupcategories_test PRIVATE
    ${CMAKE_SOURCE_DIR}/src
)
target_link_libraries(safemodebackupcategories_test PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Qml
    KF6::I18n
)
add_test(NAME safemodebackupcategories_test COMMAND safemodebackupcategories_test)

add_executable(safemodebackuprestore_test
    safemodebackuprestore_test.cpp
    ${CMAKE_SOURCE_DIR}/src/safemodebackupcategories.cpp
    ${CMAKE_SOURCE_DIR}/src/safemodebackuprestore.cpp
    ${CMAKE_BINARY_DIR}/src/welcome_debug.cpp
)
target_include_directories(safemodebackuprestore_test PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_BINARY_DIR}/src
)
target_link_libraries(safemodebackuprestore_test PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Qml
    KF6::CoreAddons
    KF6::I18n
    KF6::KIOCore
    KF6::KIOGui
)
add_test(NAME safemodebackuprestore_test COMMAND safemodebackuprestore_test)

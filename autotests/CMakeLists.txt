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

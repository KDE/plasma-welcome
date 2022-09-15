add_executable(plasma-welcome main.cpp about.cpp controller.cpp resources.qrc module.cpp)
target_link_libraries(plasma-welcome
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::DBusAddons
    KF5::KIOGui
    KF5::NetworkManagerQt
    KF5::Notifications
    KF5::QuickAddons
    KF5::Service
    KF5::WindowSystem
)
install(TARGETS plasma-welcome ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

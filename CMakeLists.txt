cmake_minimum_required(VERSION 3.21)

project(UnaLoyalty VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.12 REQUIRED COMPONENTS Quick Network)

# Setările standard Qt 6: moc automat, resursele QML sub :/qt/qml/ etc.
qt_standard_project_setup(REQUIRES 6.12)

# Modulul QML ajunge în build/qml/: de acolo îl găsesc aplicația,
# compilatorul QML și editorul din Qt Creator.
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)

qt_add_executable(UnaLoyalty
    src/main.cpp
)

# Theme e singleton: o singură instanță, folosită direct ca Theme.background etc.
set_source_files_properties(src/theme/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# Tot proiectul e un singur modul QML: în fiecare fișier QML, `import UnaLoyalty`
# aduce tema, paginile și componentele. Folderele sunt doar pentru ordine.
# Pagină / componentă / clasă nouă = o linie sub funcționalitatea ei.
qt_add_qml_module(UnaLoyalty
    URI UnaLoyalty
    VERSION 1.0
    QML_FILES
        src/Main.qml

        # Tema
        src/theme/Theme.qml

        # Componente (refolosibile; numele încep cu App)
        src/components/buttons/AppButton.qml
        src/components/buttons/AppBackButton.qml

        # Carduri
        src/cards/CardListPage.qml
        src/cards/CardTile.qml
        src/cards/CardDetailsPage.qml

        # Profil
        src/profile/ProfilePage.qml
    SOURCES
        # Comun
        src/core/apiclient.h
        src/core/apiclient.cpp

        # Componente C++
        src/components/qrcode/appqrcode.h
        src/components/qrcode/appqrcode.cpp

        # Carduri
        src/cards/models/cardsmodel.h
        src/cards/models/cardsmodel.cpp
        src/cards/models/cardsservice.h
        src/cards/models/cardsservice.cpp
)

# În C++: #include "core/apiclient.h"
target_include_directories(UnaLoyalty PRIVATE src)

# Folderele cu clase C++ pentru QML (QML_ELEMENT): Qt le include doar după numele
# fișierului, deci fiecare folder de felul ăsta se adaugă aici.
target_include_directories(UnaLoyalty PRIVATE
    src/components/qrcode
    src/cards/models
)

# Biblioteci externe, aduse ca fișiere sursă (vezi docs/SCOP.md, „Biblioteci externe”).
# QR Code generator de Project Nayuki, MIT: calculează pătrățelele codului QR.
target_sources(UnaLoyalty PRIVATE
    src/3rdparty/qrcodegen/qrcodegen.hpp
    src/3rdparty/qrcodegen/qrcodegen.cpp
)

set_target_properties(UnaLoyalty PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# Android. Identificatorul (md.una.loyalty) stă doar în android/AndroidManifest.xml.
set_target_properties(UnaLoyalty PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    QT_ANDROID_APP_NAME "UnaLoyalty"
    # versionName = versiunea din project() de sus; versionCode crește cu 1 la fiecare
    # publicare în Google Play.
    QT_ANDROID_VERSION_NAME "${PROJECT_VERSION}"
    QT_ANDROID_VERSION_CODE 1
    # Google Play cere targetSdk >= 36.
    QT_ANDROID_TARGET_SDK_VERSION 36
)

target_link_libraries(UnaLoyalty PRIVATE
    Qt6::Quick
    Qt6::Network
)

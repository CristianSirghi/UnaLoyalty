cmake_minimum_required(VERSION 3.21)

project(UnaLoyalty VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.12 REQUIRED COMPONENTS Quick Network LinguistTools)

# Setările standard Qt 6: moc automat, resursele QML sub :/qt/qml/ etc.
# Limbile: textele din cod sunt în engleză (qsTr / tr), traduse în română și rusă
# (vezi „Traduceri” mai jos).
qt_standard_project_setup(REQUIRES 6.12
    I18N_SOURCE_LANGUAGE en
    I18N_TRANSLATED_LANGUAGES ro ru
)

# Modulul QML ajunge în build/qml/: de acolo îl găsesc aplicația,
# compilatorul QML și editorul din Qt Creator.
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
# Editorul din Qt Creator caută modulele doar în căile Qt și în QML_IMPORT_PATH din
# CMakeCache.txt. Fără linia asta, cu kitul Android, `import UnaLoyalty` apare ca
# „QML module not found” (doar în editor; build-ul merge oricum).
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Căile QML pentru editorul Qt Creator" FORCE)

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
        src/components/icons/AppIcon.qml
        src/components/buttons/AppButton.qml
        src/components/buttons/AppIconButton.qml
        src/components/buttons/AppBackButton.qml
        src/components/buttons/AppSegmentedControl.qml
        src/components/navigation/AppNavBar.qml
        src/components/navigation/AppStatusBarScrim.qml
        src/components/navigation/AppPageHeader.qml
        src/components/containers/AppFlickable.qml
        src/components/display/AppValueRow.qml
        src/components/inputs/AppTextField.qml
        src/components/inputs/AppCodeField.qml
        src/components/dialogs/AppDialog.qml

        # Carduri
        src/cards/WalletPage.qml
        src/cards/WalletCard.qml
        src/cards/WalletStatTile.qml
        src/cards/AddCardSlide.qml
        src/cards/CardCodePopup.qml
        src/cards/LocalBadge.qml

        # Istoric (bonuri)
        src/history/ReceiptRow.qml
        src/history/ReceiptsEmptyState.qml
        src/history/ReceiptDetailsPage.qml
        src/history/ReceiptList.qml
        src/history/ReceiptsHistoryPage.qml

        # Profil
        src/profile/ProfilePage.qml
        src/profile/ProfileRow.qml
        src/profile/AboutPage.qml
    SOURCES
        # Comun
        src/core/apiclient.h
        src/core/apiclient.cpp
        src/core/serverconfig.h
        src/core/screenbrightness.h
        src/core/screenbrightness.cpp
        src/core/systembars.h
        src/core/systembars.cpp
        src/core/format.h
        src/core/format.cpp

        # Componente C++
        src/components/qrcode/appqrcode.h
        src/components/qrcode/appqrcode.cpp

        # Carduri
        src/cards/models/cardsmodel.h
        src/cards/models/cardsmodel.cpp
        src/cards/models/cardsservice.h
        src/cards/models/cardsservice.cpp

        # Istoric (bonuri)
        src/history/models/receiptsmodel.h
        src/history/models/receiptsmodel.cpp
        src/history/models/receiptlinesmodel.h
        src/history/models/receiptlinesmodel.cpp

        # Profil
        src/profile/models/profileservice.h
        src/profile/models/profileservice.cpp

        # Contul (înregistrare, intrare, sesiune)
        src/auth/models/sessionservice.h
        src/auth/models/sessionservice.cpp
)

# Versiunea din project() de sus ajunge în aplicație (pagina „About the app”).
target_compile_definitions(UnaLoyalty PRIVATE APP_VERSION="${PROJECT_VERSION}")

# În C++: #include "core/apiclient.h"
target_include_directories(UnaLoyalty PRIVATE src)

# Folderele cu clase C++ pentru QML (QML_ELEMENT): Qt le include doar după numele
# fișierului, deci fiecare folder de felul ăsta se adaugă aici.
target_include_directories(UnaLoyalty PRIVATE
    src/core
    src/components/qrcode
    src/cards/models
    src/history/models
    src/profile/models
    src/auth/models
)

# Biblioteci externe, aduse ca fișiere sursă (vezi docs/SCOP.md, „Biblioteci externe”).
# QR Code generator de Project Nayuki, MIT: calculează pătrățelele codului QR.
target_sources(UnaLoyalty PRIVATE
    src/3rdparty/qrcodegen/qrcodegen.hpp
    src/3rdparty/qrcodegen/qrcodegen.cpp
)

# Traduceri: i18n/unaloyalty_ro.ts și _ru.ts (plus _en.ts, doar pentru formele de plural).
# Text nou în cod → `cmake --build <build> --target update_translations` adaugă textul în
# fișierele .ts, apoi se completează traducerea (Qt Linguist sau direct în fișier).
# La build, .ts devin .qm și intră în aplicație sub :/i18n.
set_property(TARGET UnaLoyalty PROPERTY QT_EXCLUDE_SOURCES_FROM_TRANSLATION "src/3rdparty/*")
qt_add_translations(UnaLoyalty
    SOURCE_TARGETS UnaLoyalty
    TS_FILE_BASE unaloyalty
    TS_OUTPUT_DIRECTORY i18n
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

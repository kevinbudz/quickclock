import QtQuick

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Formatting")
        icon: "format-text-code"
        source: "configFormatting.qml"
    }
}

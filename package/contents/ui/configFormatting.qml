import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: formattingPage

    readonly property var bbcodeRows: [
        { token: "[b]", description: i18n("Bold text") },
        { token: "[i]", description: i18n("Italic text") },
        { token: "[u]", description: i18n("Underline text") },
        { token: "[s]", description: i18n("Strikethrough text") },
        { token: "[size=12]", description: i18n("Font size in pt, or a multiple ≤ 4 of the base size (e.g. 2 doubles it)") },
        { token: "[color=#fff]", description: i18n("Text color (hex or CSS color name)") },
        { token: "[weight=Bold]", description: i18n("Font weight (name or 100–1000); falls back to Regular if unavailable") },
        { token: "[center]", description: i18n("Centered block; put each line on its own row") },
        { token: "[left]", description: i18n("Left-aligned block") },
        { token: "[right]", description: i18n("Right-aligned block") }
    ]

    readonly property var dateTimeRows: [
        { token: "hh", description: i18n("Hour, 12-hour clock, with leading zero") },
        { token: "h", description: i18n("Hour, 12-hour clock, no leading zero") },
        { token: "HH", description: i18n("Hour, 24-hour clock, with leading zero") },
        { token: "H", description: i18n("Hour, 24-hour clock, no leading zero") },
        { token: "mm", description: i18n("Minute, with leading zero") },
        { token: "m", description: i18n("Minute, no leading zero") },
        { token: "AP", description: i18n("AM or PM") },
        { token: "ap", description: i18n("am or pm") },
        { token: "d", description: i18n("Day of month, no leading zero") },
        { token: "dd", description: i18n("Day of month, with leading zero") },
        { token: "M", description: i18n("Month, no leading zero") },
        { token: "MM", description: i18n("Month, with leading zero") },
        { token: "MMM", description: i18n("Short month name") },
        { token: "MMMM", description: i18n("Long month name") },
        { token: "ddd", description: i18n("Short day name") },
        { token: "dddd", description: i18n("Long day name") },
        { token: "yy", description: i18n("Two-digit year") },
        { token: "yyyy", description: i18n("Four-digit year") }
    ]

    Kirigami.FormLayout {
        ColumnLayout {
            Kirigami.FormData.label: " "
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 4
                    type: Kirigami.Heading.Type.Primary
                    text: i18n("BBCode")
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: i18n("Wrap text in opening and closing tags, e.g. [b]bold[/b]. Blocks like [center]…[/center] can span multiple lines; use a new line for each row.")
                }

                TokenTable {
                    Layout.fillWidth: true
                    rows: formattingPage.bbcodeRows
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 4
                    type: Kirigami.Heading.Type.Primary
                    text: i18n("Date & time")
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: i18n("Place tokens directly in the format string (no brackets). Longer tokens such as MMM are matched before shorter ones like M.")
                }

                TokenTable {
                    Layout.fillWidth: true
                    rows: formattingPage.dateTimeRows
                }
            }
        }
    }

    component TokenTable: Rectangle {
        id: table

        required property var rows

        readonly property real tokenColumnWidth: Kirigami.Units.gridUnit * 7
        readonly property real cellVMargin: Kirigami.Units.smallSpacing
        readonly property real cellHMargin: Kirigami.Units.mediumSpacing

        implicitWidth: tokenColumnWidth + Kirigami.Units.gridUnit * 18
        implicitHeight: tableBody.implicitHeight
        color: Kirigami.Theme.alternateBackgroundColor !== undefined
            ? Kirigami.Theme.alternateBackgroundColor
            : Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.separatorColor !== undefined
            ? Kirigami.Theme.separatorColor
            : Kirigami.Theme.disabledTextColor
        radius: Kirigami.Units.cornerRadius

        ColumnLayout {
            id: tableBody
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                QQC2.Label {
                    text: i18n("Token")
                    font.bold: true
                    Layout.preferredWidth: table.tokenColumnWidth
                    Layout.maximumWidth: table.tokenColumnWidth
                    Layout.leftMargin: table.cellHMargin
                    Layout.topMargin: table.cellVMargin
                    Layout.bottomMargin: table.cellVMargin
                }
                QQC2.Label {
                    text: i18n("Function")
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.rightMargin: table.cellHMargin
                    Layout.topMargin: table.cellVMargin
                    Layout.bottomMargin: table.cellVMargin
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Repeater {
                model: table.rows

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.mediumSpacing

                        QQC2.Label {
                            text: modelData.token
                            font.family: Kirigami.Theme.fixedFont && Kirigami.Theme.fixedFont.family
                                ? Kirigami.Theme.fixedFont.family
                                : "monospace"
                            Layout.preferredWidth: table.tokenColumnWidth
                            Layout.maximumWidth: table.tokenColumnWidth
                            Layout.leftMargin: table.cellHMargin
                            Layout.topMargin: table.cellVMargin
                            Layout.bottomMargin: table.cellVMargin
                        }
                        QQC2.Label {
                            text: modelData.description
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.rightMargin: table.cellHMargin
                            Layout.topMargin: table.cellVMargin
                            Layout.bottomMargin: table.cellVMargin
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        visible: index < table.rows.length - 1
                    }
                }
            }
        }
    }
}

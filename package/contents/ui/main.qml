import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import "code/formatEngine.js" as FormatEngine
import "code/bbcode.js" as BBCode
import "code/presets.js" as Presets

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    property var now: new Date()

    readonly property bool usingSystemFont: Plasmoid.configuration.useSystemFont

    readonly property string activeTemplate: Presets.resolveActiveTemplate(
        Plasmoid.configuration.formatPreset,
        Plasmoid.configuration.customFormat
    )

    readonly property string expandedText: FormatEngine.expand(
        activeTemplate,
        now,
        Plasmoid.configuration.use24hFormat,
        Qt.locale(),
        Locale.ShortFormat,
        Locale.LongFormat
    )

    readonly property real baseFontSize: usingSystemFont
        ? Kirigami.Theme.defaultFont.pointSize
        : (Plasmoid.configuration.fontSize > 0 ? Plasmoid.configuration.fontSize : 10)

    readonly property bool usesBbcode: BBCode.hasBbcodeMarkup(activeTemplate)

    readonly property string richHtml: BBCode.toHtml(expandedText, baseFontSize)

    readonly property font labelFont: usingSystemFont
        ? Kirigami.Theme.defaultFont
        : Qt.font({
            family: Plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family,
            pointSize: baseFontSize,
            bold: Plasmoid.configuration.boldText
        })

    fullRepresentation: Item {
        readonly property real minWidth: Math.max(clockText.contentWidth, Kirigami.Units.gridUnit * 3)
        readonly property real minHeight: Math.max(clockText.contentHeight, Kirigami.Units.gridUnit * 2)

        Layout.minimumWidth: minWidth
        Layout.minimumHeight: minHeight
        Layout.preferredWidth: minWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: minHeight

        implicitWidth: minWidth
        implicitHeight: minHeight

        ClockLabel {
            id: clockText

            anchors.centerIn: parent
            width: contentWidth
            height: contentHeight

            plainText: root.expandedText
            richHtml: root.richHtml
            richMode: root.usesBbcode
            font: root.labelFont
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    function refreshNow() {
        now = new Date();
    }

    function scheduleMidnightRefresh() {
        const next = new Date(now);
        next.setHours(24, 0, 0, 0);
        midnightTimer.interval = Math.max(1000, next.getTime() - Date.now());
        midnightTimer.restart();
    }

    Timer {
        id: midnightTimer
        repeat: true
        running: true
        onTriggered: {
            root.refreshNow();
            root.scheduleMidnightRefresh();
        }
        Component.onCompleted: root.scheduleMidnightRefresh()
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.refreshNow()
    }
}

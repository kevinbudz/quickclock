import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.digitalclock as DigitalClock
import org.kde.plasma.workspace.calendar as PlasmaCalendar

import "code/formatEngine.js" as FormatEngine
import "code/bbcode.js" as BBCode
import "code/fontHelpers.js" as FontHelpers
import "code/presets.js" as Presets

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation
    hideOnWindowDeactivate: true

    toolTipMainText: tooltipUsesBbcode ? "" : tooltipMainLine(expandedTooltipText)
    toolTipSubText: tooltipUsesBbcode ? tooltipHtml : tooltipRemainingText(expandedTooltipText)
    toolTipTextFormat: tooltipUsesBbcode ? Text.RichText : Text.PlainText

    property var now: new Date()

    readonly property bool usingSystemFont: Plasmoid.configuration.useSystemFont

    readonly property string timezoneCity: {
        const city = timeZoneModel.localTimeZoneCity();
        return city ? city : i18n("Local");
    }

    readonly property var formatExtraTokens: ({ tz: timezoneCity })

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
        Locale.LongFormat,
        formatExtraTokens
    )

    readonly property real baseFontSize: usingSystemFont
        ? Kirigami.Theme.defaultFont.pointSize
        : (Plasmoid.configuration.fontSize > 0 ? Plasmoid.configuration.fontSize : 10)

    readonly property font labelFont: usingSystemFont
        ? Kirigami.Theme.defaultFont
        : FontHelpers.resolveFont(
            Plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family,
            Plasmoid.configuration.fontStyle || "Regular",
            baseFontSize,
            Plasmoid.configuration.italicText,
            Plasmoid.configuration.strikeoutText
        )

    readonly property bool usesBbcode: BBCode.hasBbcodeMarkup(activeTemplate)

    readonly property string richHtml: BBCode.toHtml(expandedText, baseFontSize, labelFont.family)

    readonly property string activeTooltipTemplate: Presets.resolveActiveTooltipTemplate(
        Plasmoid.configuration.tooltipPreset,
        Plasmoid.configuration.customTooltipFormat
    )

    readonly property string expandedTooltipText: FormatEngine.expand(
        activeTooltipTemplate,
        now,
        Plasmoid.configuration.use24hFormat,
        Qt.locale(),
        Locale.ShortFormat,
        Locale.LongFormat,
        formatExtraTokens
    )

    readonly property bool tooltipUsesBbcode: BBCode.hasBbcodeMarkup(activeTooltipTemplate)

    readonly property string tooltipHtml: BBCode.toTooltipHtml(
        expandedTooltipText,
        Kirigami.Theme.defaultFont.pointSize,
        Kirigami.Theme.defaultFont.family
    )

    DigitalClock.TimeZoneModel {
        id: timeZoneModel

        Component.onCompleted: selectLocalTimeZone()
    }

    compactRepresentation: Item {
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

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 18
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22

        implicitWidth: Layout.preferredWidth
        implicitHeight: Layout.preferredHeight

        PlasmaCalendar.EventPluginsManager {
            id: eventPluginsManager
        }

        PlasmaCalendar.MonthView {
            id: calendarView

            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            eventPluginsManager: eventPluginsManager
            today: root.now
        }

        Connections {
            target: root

            function onExpandedChanged() {
                if (root.expanded) {
                    calendarView.resetToToday();
                }
            }
        }
    }

    function refreshNow() {
        now = new Date();
    }

    function tooltipMainLine(text) {
        const lines = (text || "").split(/\r?\n/);
        return lines.length > 0 ? lines[0] : "";
    }

    function tooltipRemainingText(text) {
        const lines = (text || "").split(/\r?\n/);
        return lines.length > 1 ? lines.slice(1).join("\n") : "";
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

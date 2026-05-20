import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.digitalclock as DigitalClock

import "code/formatEngine.js" as FormatEngine
import "code/bbcode.js" as BBCode
import "code/presets.js" as Presets

KCMUtils.SimpleKCM {
    id: appearancePage

    readonly property string plasmaTemplate: Presets.PLASMA
    readonly property string tooltipTemplate: Presets.TOOLTIP_DIGITAL_CLOCK

    property string cfg_formatPreset: "plasma"
    property string cfg_customFormat: plasmaTemplate
    property bool cfg_customFormatEdited: false
    property string cfg_lastPresetFormat: plasmaTemplate
    property string cfg_tooltipPreset: "digitalClock"
    property string cfg_customTooltipFormat: tooltipTemplate
    property bool cfg_customTooltipEdited: false
    property string cfg_lastPresetTooltipFormat: tooltipTemplate
    property alias cfg_use24hFormat: use24hFormat.currentIndex
    property alias cfg_useSystemFont: useSystemFont.checked
    property alias cfg_fontFamily: fontRow.fontFamily
    property alias cfg_fontSize: fontRow.fontSize
    property alias cfg_fontStyle: fontRow.fontStyle
    property alias cfg_italicText: fontRow.italicText
    property alias cfg_strikeoutText: fontRow.strikeoutText
    property alias cfg_boldText: fontRow.boldText

    readonly property font previewLabelFont: useSystemFont.checked
        ? Kirigami.Theme.defaultFont
        : fontRow.currentFont

    readonly property string displayedClockFormat: cfg_formatPreset === "custom"
        ? cfg_customFormat
        : Presets.template(cfg_formatPreset)

    readonly property string displayedTooltipFormat: cfg_tooltipPreset === "custom"
        ? cfg_customTooltipFormat
        : Presets.tooltipTemplate(cfg_tooltipPreset)

    readonly property bool previewUsesBbcode: BBCode.hasBbcodeMarkup(displayedClockFormat)

    readonly property string previewTimeZoneCity: {
        const city = timeZoneModel.localTimeZoneCity();
        return city ? city : i18n("Local");
    }

    readonly property string previewExpanded: FormatEngine.expand(
        displayedClockFormat,
        new Date(),
        use24hFormat.currentIndex,
        Qt.locale(),
        Locale.ShortFormat,
        Locale.LongFormat,
        { tz: previewTimeZoneCity }
    )

    readonly property string previewHtml: BBCode.toHtml(
        previewExpanded,
        previewLabelFont.pointSize,
        previewLabelFont.family
    )

    readonly property string previewTooltipExpanded: FormatEngine.expand(
        displayedTooltipFormat,
        new Date(),
        use24hFormat.currentIndex,
        Qt.locale(),
        Locale.ShortFormat,
        Locale.LongFormat,
        { tz: previewTimeZoneCity }
    )

    readonly property bool previewTooltipUsesBbcode: BBCode.hasBbcodeMarkup(displayedTooltipFormat)

    readonly property string previewTooltipHtml: BBCode.toTooltipHtml(
        previewTooltipExpanded,
        Kirigami.Theme.defaultFont.pointSize,
        Kirigami.Theme.defaultFont.family
    )

    function applyPresetSelection(presetId) {
        if (presetId === "custom") {
            if (!cfg_customFormatEdited) {
                cfg_customFormat = cfg_lastPresetFormat;
            }
        } else {
            cfg_lastPresetFormat = Presets.template(presetId);
            cfg_customFormatEdited = false;
        }
        cfg_formatPreset = presetId;
    }

    function applyTooltipPresetSelection(presetId) {
        if (presetId === "custom") {
            if (!cfg_customTooltipEdited) {
                cfg_customTooltipFormat = cfg_lastPresetTooltipFormat;
            }
        } else {
            cfg_lastPresetTooltipFormat = Presets.tooltipTemplate(presetId);
            cfg_customTooltipEdited = false;
        }
        cfg_tooltipPreset = presetId;
    }

    DigitalClock.TimeZoneModel {
        id: timeZoneModel

        Component.onCompleted: selectLocalTimeZone()
    }

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
                    text: i18n("Clock")
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true

                    QQC2.ComboBox {
                        id: presetCombo
                        Kirigami.FormData.label: i18n("Layout:")
                        model: [
                            i18n("Plasma"),
                            i18n("Pear"),
                            i18n("Custom")
                        ]
                        onActivated: appearancePage.applyPresetSelection(Presets.presetIdFromIndex(currentIndex))
                        Component.onCompleted: {
                            currentIndex = Presets.presetIndex(appearancePage.cfg_formatPreset);
                        }
                        Connections {
                            target: appearancePage
                            function onCfg_formatPresetChanged() {
                                const index = Presets.presetIndex(appearancePage.cfg_formatPreset);
                                if (presetCombo.currentIndex !== index) {
                                    presetCombo.currentIndex = index;
                                }
                            }
                        }
                    }

                    QQC2.TextArea {
                        id: customFormatField
                        Kirigami.FormData.label: i18n("Format:")
                        Layout.fillWidth: true
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
                        enabled: appearancePage.cfg_formatPreset === "custom"
                        wrapMode: TextEdit.Wrap
                        placeholderText: appearancePage.plasmaTemplate
                        text: appearancePage.displayedClockFormat
                        onTextChanged: {
                            if (appearancePage.cfg_formatPreset !== "custom") {
                                return;
                            }
                            if (text !== appearancePage.cfg_customFormat) {
                                appearancePage.cfg_customFormat = text;
                                appearancePage.cfg_customFormatEdited = true;
                            }
                        }
                    }

                    ClockLabel {
                        id: previewLabel
                        Kirigami.FormData.label: i18n("Preview:")
                        width: Math.max(contentWidth, Kirigami.Units.gridUnit * 12)
                        height: contentHeight
                        plainText: appearancePage.previewExpanded
                        richHtml: appearancePage.previewHtml
                        richMode: appearancePage.previewUsesBbcode
                        font: appearancePage.previewLabelFont
                    }

                    QQC2.ComboBox {
                        id: use24hFormat
                        Kirigami.FormData.label: i18n("Time format:")
                        model: [
                            i18nc("@item:inlistbox", "12-hour"),
                            i18nc("@item:inlistbox", "Use region defaults"),
                            i18nc("@item:inlistbox", "24-hour")
                        ]
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 4
                    type: Kirigami.Heading.Type.Primary
                    text: i18n("Tooltip")
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true

                    QQC2.ComboBox {
                        id: tooltipPresetCombo
                        Kirigami.FormData.label: i18n("Layout:")
                        model: [
                            i18n("Plasma"),
                            i18n("Pear"),
                            i18n("Custom")
                        ]
                        onActivated: appearancePage.applyTooltipPresetSelection(Presets.tooltipPresetIdFromIndex(currentIndex))
                        Component.onCompleted: {
                            currentIndex = Presets.tooltipPresetIndex(appearancePage.cfg_tooltipPreset);
                        }
                        Connections {
                            target: appearancePage
                            function onCfg_tooltipPresetChanged() {
                                const index = Presets.tooltipPresetIndex(appearancePage.cfg_tooltipPreset);
                                if (tooltipPresetCombo.currentIndex !== index) {
                                    tooltipPresetCombo.currentIndex = index;
                                }
                            }
                        }
                    }

                    QQC2.TextArea {
                        id: customTooltipField
                        Kirigami.FormData.label: i18n("Format:")
                        Layout.fillWidth: true
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
                        enabled: appearancePage.cfg_tooltipPreset === "custom"
                        wrapMode: TextEdit.Wrap
                        placeholderText: appearancePage.tooltipTemplate
                        text: appearancePage.displayedTooltipFormat
                        onTextChanged: {
                            if (appearancePage.cfg_tooltipPreset !== "custom") {
                                return;
                            }
                            if (text !== appearancePage.cfg_customTooltipFormat) {
                                appearancePage.cfg_customTooltipFormat = text;
                                appearancePage.cfg_customTooltipEdited = true;
                            }
                        }
                    }

                    QQC2.Label {
                        Kirigami.FormData.label: i18n("Preview:")
                        Layout.fillWidth: true
                        text: appearancePage.previewTooltipUsesBbcode
                            ? appearancePage.previewTooltipHtml
                            : appearancePage.previewTooltipExpanded
                        textFormat: appearancePage.previewTooltipUsesBbcode ? Text.RichText : Text.PlainText
                        wrapMode: Text.Wrap
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 4
                    type: Kirigami.Heading.Type.Primary
                    text: i18n("Font")
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true

                    QQC2.CheckBox {
                        id: useSystemFont
                        Kirigami.FormData.label: " "
                        text: i18n("Use system panel font")
                    }

                    FontSettingsRow {
                        id: fontRow
                        Kirigami.FormData.label: " "
                        enabled: !useSystemFont.checked
                    }
                }
            }
        }
    }
}

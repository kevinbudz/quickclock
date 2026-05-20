import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

import "code/formatEngine.js" as FormatEngine
import "code/bbcode.js" as BBCode
import "code/presets.js" as Presets

KCMUtils.SimpleKCM {
    id: appearancePage

    readonly property string plasmaTemplate: Presets.PLASMA

    property string cfg_formatPreset: "plasma"
    property string cfg_customFormat: plasmaTemplate
    property bool cfg_customFormatEdited: false
    property string cfg_lastPresetFormat: plasmaTemplate
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

    readonly property int previewFontSize: previewLabelFont.pointSize

    readonly property string previewTemplate: cfg_formatPreset === "custom"
        ? customFormatField.text
        : Presets.template(cfg_formatPreset)

    readonly property bool previewUsesBbcode: BBCode.hasBbcodeMarkup(previewTemplate)

    readonly property string previewExpanded: FormatEngine.expand(
        previewTemplate,
        new Date(),
        use24hFormat.currentIndex,
        Qt.locale(),
        Locale.ShortFormat,
        Locale.LongFormat
    )

    readonly property string previewHtml: BBCode.toHtml(previewExpanded, previewFontSize, previewLabelFont.family)

    function applyPresetSelection(presetId) {
        if (presetId === "custom") {
            if (!cfg_customFormatEdited) {
                cfg_customFormat = cfg_lastPresetFormat;
            }
            customFormatField.text = cfg_customFormat;
        } else {
            cfg_lastPresetFormat = Presets.template(presetId);
            cfg_customFormatEdited = false;
        }
        cfg_formatPreset = presetId;
    }

    Kirigami.FormLayout {
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
            Kirigami.FormData.label: i18n("Custom format:")
            Layout.fillWidth: true
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
            enabled: appearancePage.cfg_formatPreset === "custom"
            wrapMode: TextEdit.Wrap
            placeholderText: appearancePage.plasmaTemplate
            text: appearancePage.cfg_customFormat
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: useSystemFont
            Kirigami.FormData.label: i18n("Font:")
            text: i18n("Use system panel font")
        }

        FontSettingsRow {
            id: fontRow
            enabled: !useSystemFont.checked
        }
    }
}

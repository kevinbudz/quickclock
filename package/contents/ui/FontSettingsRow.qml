import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "code/fontHelpers.js" as FontHelpers

ColumnLayout {
    id: root

    Layout.fillWidth: true

    property string fontFamily: ""
    property int fontSize: 10
    property string fontStyle: "Regular"
    property bool italicText: false
    property bool strikeoutText: false
    /** @deprecated Kept for config migration from boldText. */
    property bool boldText: false

    readonly property font currentFont: FontHelpers.resolveFont(
        resolvedFamily(),
        fontStyle,
        fontSize > 0 ? fontSize : Kirigami.Theme.defaultFont.pointSize,
        italicText,
        strikeoutText
    )

    readonly property string fontSummary: i18nc(
        "@label selected font summary, %1 is family, %2 is style, %3 is point size",
        "%1, %2, %3 pt",
        currentFont.family,
        FontHelpers.styleFromFont(currentFont),
        Math.round(currentFont.pointSize)
    )

    function resolvedFamily() {
        return fontFamily || Kirigami.Theme.defaultFont.family;
    }

    function migrateLegacyBold() {
        if (!boldText || fontStyle !== "Regular") {
            return;
        }
        fontStyle = italicText ? "Bold Italic" : "Bold";
        italicText = false;
        boldText = false;
    }

    function openFontDialog() {
        fontDialog.selectedFont = currentFont;
        fontDialog.open();
    }

    function applyFont(font) {
        fontFamily = font.family || resolvedFamily();
        fontStyle = FontHelpers.styleFromFont(font);
        if (font.pointSize > 0) {
            fontSize = Math.round(font.pointSize);
        }
        italicText = false;
        strikeoutText = font.strikeout;
        boldText = false;
    }

    Component.onCompleted: migrateLegacyBold()

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.fontSummary
        }

        QQC2.Button {
            text: i18nc("@action:button", "Choose Font...")
            onClicked: root.openFontDialog()
        }
    }

    Dialogs.FontDialog {
        id: fontDialog

        title: i18nc("@title:window", "Choose Font")
        onAccepted: root.applyFont(selectedFont)
    }
}

import QtQuick

import org.kde.kirigami as Kirigami

Text {
    property string plainText: ""
    property string richHtml: ""
    property bool richMode: false

    text: richMode ? richHtml : plainText
    textFormat: richMode ? Text.RichText : Text.PlainText
    color: Kirigami.Theme.textColor
    lineHeight: 1
    lineHeightMode: Text.ProportionalHeight
    wrapMode: Text.NoWrap
}

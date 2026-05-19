.pragma library

var BLOCK_STYLE = "margin:0;padding:0;line-height:100%;white-space:pre-wrap";

function escapeHtml(text) {
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
}

function preserveConsecutiveSpaces(text) {
    return text.replace(/ {2,}/g, function (run) {
        return " " + "\u00A0".repeat(run.length - 1);
    });
}

function hasBbcodeMarkup(source) {
    if (!source) {
        return false;
    }
    return /\[(?:\/)?(?:b|i|u|s|center|left|right)\]|\[(?:\/)?(?:size|color)=/i.test(source);
}

function parseSize(value, baseFontPt) {
    const numeric = parseFloat(value);
    if (isNaN(numeric)) {
        return baseFontPt + "pt";
    }
    if (value.indexOf("pt") >= 0 || value.indexOf("px") >= 0 || value.indexOf("em") >= 0) {
        return value;
    }
    if (numeric <= 4) {
        return (baseFontPt * numeric).toFixed(1) + "pt";
    }
    return numeric + "pt";
}

function wrapAlignBlock(tag, align, content) {
    const inner = preserveConsecutiveSpaces(content.replace(/\n/g, "<br/>"));
    return "<" + tag + " align=\"" + align + "\" style=\"" + BLOCK_STYLE + "\">"
        + inner + "</" + tag + ">";
}

function collapseBlockBreaks(html) {
    return html
        .replace(/<\/p>[ \t\r\n\f]*(?:<br\s*\/?>[ \t\r\n\f]*)+/gi, "</p>")
        .replace(/(?:[ \t\r\n\f]*<br\s*\/?>[ \t\r\n\f]*)+<p/gi, "<p")
        .replace(/<\/p>[ \t\r\n\f]*(?:<br\s*\/?>[ \t\r\n\f]*)+(?=<span)/gi, "</p>")
        .replace(/<\/span>[ \t\r\n\f]*(?:<br\s*\/?>[ \t\r\n\f]*)+(?=<p)/gi, "</span>")
        .replace(/<\/div>[ \t\r\n\f]*(?:<br\s*\/?>[ \t\r\n\f]*)+/gi, "</div>")
        .replace(/(?:[ \t\r\n\f]*<br\s*\/?>[ \t\r\n\f]*)+<div/gi, "<div");
}

function balanceSpans(html) {
    const opens = (html.match(/<span\b/gi) || []).length;
    const closes = (html.match(/<\/span>/gi) || []).length;
    let result = html;
    for (let i = closes; i < opens; i++) {
        result += "</span>";
    }
    return result;
}

function toHtml(source, baseFontPt) {
    if (!source) {
        return "";
    }

    const base = baseFontPt > 0 ? baseFontPt : 10;
    let html = preserveConsecutiveSpaces(escapeHtml(source));

    html = html.replace(/\[\/(center|left|right)\]\[size=([^\]]+)\]/gi, "[/$1][/size]");

    const inlineTags = [
        { open: /\[b\]/gi, close: /\[\/b\]/gi, tag: "b" },
        { open: /\[i\]/gi, close: /\[\/i\]/gi, tag: "i" },
        { open: /\[u\]/gi, close: /\[\/u\]/gi, tag: "u" },
        { open: /\[s\]/gi, close: /\[\/s\]/gi, tag: "s" }
    ];

    for (let r = 0; r < inlineTags.length; r++) {
        const rule = inlineTags[r];
        html = html.replace(rule.open, "<" + rule.tag + ">").replace(rule.close, "</" + rule.tag + ">");
    }

    html = html.replace(/\[size=([^\]]+)\]/gi, function(_, size) {
        return "<span style=\"font-size:" + parseSize(size.trim(), base) + ";\">";
    }).replace(/\[\/size(?:=[^\]]*)?\]/gi, "</span>");

    html = html.replace(/\[color=([^\]]+)\]/gi, function(_, color) {
        return "<span style=\"color:" + color.trim() + ";\">";
    }).replace(/\[\/color\]/gi, "</span>");

    html = html.replace(/\[center\]([\s\S]*?)\[\/center\]/gi, function(_, content) {
        return wrapAlignBlock("p", "center", content);
    });
    html = html.replace(/\[left\]([\s\S]*?)\[\/left\]/gi, function(_, content) {
        return wrapAlignBlock("p", "left", content);
    });
    html = html.replace(/\[right\]([\s\S]*?)\[\/right\]/gi, function(_, content) {
        return wrapAlignBlock("p", "right", content);
    });

    html = html.replace(/\n/g, "<br/>");
    html = collapseBlockBreaks(html);
    html = balanceSpans(html);

    return "<style type=\"text/css\">p,div{white-space:pre-wrap;}</style>"
        + "<div style=\"" + BLOCK_STYLE + "\">" + html + "</div>";
}

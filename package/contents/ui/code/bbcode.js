.pragma library
.import "fontHelpers.js" as FontHelpers

var BLOCK_STYLE = "margin:0;padding:0;line-height:100%;white-space:pre-wrap";

var INLINE_TAGS = [
    { open: /\[b\]/gi, close: /\[\/b\]/gi, tag: "b" },
    { open: /\[i\]/gi, close: /\[\/i\]/gi, tag: "i" },
    { open: /\[u\]/gi, close: /\[\/u\]/gi, tag: "u" },
    { open: /\[s\]/gi, close: /\[\/s\]/gi, tag: "s" }
];

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
    return /\[(?:\/)?(?:b|i|u|s|center|left|right)\]|\[(?:\/)?(?:size|color|weight)=/i.test(source);
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

function applyInlineMarkup(html, base, family, tooltip) {
    for (let r = 0; r < INLINE_TAGS.length; r++) {
        const rule = INLINE_TAGS[r];
        html = html.replace(rule.open, "<" + rule.tag + ">").replace(rule.close, "</" + rule.tag + ">");
    }

    html = html.replace(/\[size=([^\]]+)\]/gi, function(_, size) {
        return "<span style=\"font-size:" + parseSize(size.trim(), base) + ";\">";
    }).replace(/\[\/size(?:=[^\]]*)?\]/gi, "</span>");

    if (tooltip) {
        html = html.replace(/\[color=([^\]]+)\]/gi, function(_, color) {
            return "<font color=\"" + color.trim() + "\">";
        }).replace(/\[\/color\]/gi, "</font>");
    } else {
        html = html.replace(/\[color=([^\]]+)\]/gi, function(_, color) {
            return "<span style=\"color:" + color.trim() + ";\">";
        }).replace(/\[\/color\]/gi, "</span>");
    }

    html = html.replace(/\[weight=([^\]]+)\]/gi, function(_, weight) {
        const resolved = FontHelpers.resolveWeightForFamily(family, base, weight);
        return "<span style=\"" + FontHelpers.weightSpanStyle(resolved) + ";\">";
    }).replace(/\[\/weight\]/gi, "</span>");

    return html;
}

function applyAlignBlocks(html, tooltip) {
    if (tooltip) {
        return html
            .replace(/\[center\]([\s\S]*?)\[\/center\]/gi, "<div align=\"center\">$1</div>")
            .replace(/\[left\]([\s\S]*?)\[\/left\]/gi, "<div align=\"left\">$1</div>")
            .replace(/\[right\]([\s\S]*?)\[\/right\]/gi, "<div align=\"right\">$1</div>");
    }

    return html
        .replace(/\[center\]([\s\S]*?)\[\/center\]/gi, function(_, content) {
            return wrapAlignBlock("p", "center", content);
        })
        .replace(/\[left\]([\s\S]*?)\[\/left\]/gi, function(_, content) {
            return wrapAlignBlock("p", "left", content);
        })
        .replace(/\[right\]([\s\S]*?)\[\/right\]/gi, function(_, content) {
            return wrapAlignBlock("p", "right", content);
        });
}

function convertBbcode(source, baseFontPt, fontFamily, tooltip) {
    if (!source) {
        return "";
    }

    const base = baseFontPt > 0 ? baseFontPt : 10;
    const family = (fontFamily || "").trim();
    let html = preserveConsecutiveSpaces(escapeHtml(source));

    if (!tooltip) {
        html = html.replace(/\[\/(center|left|right)\]\[size=([^\]]+)\]/gi, "[/$1][/size]");
    }

    html = applyInlineMarkup(html, base, family, tooltip);
    html = applyAlignBlocks(html, tooltip);
    html = html.replace(/\n/g, "<br/>");
    return balanceSpans(html);
}

function toTooltipHtml(source, baseFontPt, fontFamily) {
    return convertBbcode(source, baseFontPt, fontFamily, true);
}

function toHtml(source, baseFontPt, fontFamily) {
    let html = convertBbcode(source, baseFontPt, fontFamily, false);
    if (!html) {
        return "";
    }
    html = collapseBlockBreaks(html);
    return "<style type=\"text/css\">p,div{white-space:pre-wrap;}</style>"
        + "<div style=\"" + BLOCK_STYLE + "\">" + html + "</div>";
}

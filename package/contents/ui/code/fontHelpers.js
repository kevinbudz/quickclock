.pragma library

function cleanStyleName(style) {
    const normalized = (style || "").trim().replace(/\s+/g, " ");
    if (!normalized) {
        return "Regular";
    }
    if (normalized.toLowerCase() === "normal") {
        return "Regular";
    }
    return normalized;
}

function styleWeight(style) {
    const name = cleanStyleName(style).toLowerCase().replace(/[-_]+/g, " ");
    let weight = 400;
    if (name.indexOf("thin") >= 0) {
        weight = 100;
    } else if (name.indexOf("extralight") >= 0 || name.indexOf("extra light") >= 0 || name.indexOf("ultralight") >= 0 || name.indexOf("ultra light") >= 0) {
        weight = 200;
    } else if (name.indexOf("light") >= 0) {
        weight = 300;
    } else if (name.indexOf("medium") >= 0) {
        weight = 500;
    } else if (name.indexOf("demibold") >= 0 || name.indexOf("demi bold") >= 0 || name.indexOf("semibold") >= 0 || name.indexOf("semi bold") >= 0) {
        weight = 600;
    } else if (name.indexOf("extrabold") >= 0 || name.indexOf("extra bold") >= 0 || name.indexOf("ultrabold") >= 0 || name.indexOf("ultra bold") >= 0) {
        weight = 800;
    } else if (name.indexOf("bold") >= 0) {
        weight = 700;
    } else if (name.indexOf("black") >= 0 || name.indexOf("heavy") >= 0) {
        weight = 900;
    }
    return weight;
}

function styleItalic(style) {
    const name = cleanStyleName(style).toLowerCase();
    return name.indexOf("italic") >= 0 || name.indexOf("oblique") >= 0;
}

function styleFromWeight(weight, italic) {
    let style = "Regular";
    if (weight <= 150) {
        style = "Thin";
    } else if (weight <= 250) {
        style = "ExtraLight";
    } else if (weight <= 350) {
        style = "Light";
    } else if (weight <= 450) {
        style = "Regular";
    } else if (weight <= 550) {
        style = "Medium";
    } else if (weight <= 650) {
        style = "DemiBold";
    } else if (weight <= 750) {
        style = "Bold";
    } else if (weight <= 850) {
        style = "ExtraBold";
    } else {
        style = "Black";
    }
    return italic && style !== "Regular" ? style + " Italic" : (italic ? "Italic" : style);
}

function styleFromFont(font) {
    if (font.styleName) {
        return cleanStyleName(font.styleName);
    }
    return styleFromWeight(font.weight || 400, font.italic);
}

function resolveFont(family, style, pointSize, italic, strikeout) {
    const styleName = cleanStyleName(style);
    return Qt.font({
        family: family,
        pointSize: Math.max(1, pointSize),
        styleName: styleName,
        weight: styleWeight(styleName),
        italic: italic || styleItalic(styleName),
        strikeout: strikeout
    });
}

var WEIGHT_ALIASES = {
    "thin": "Thin",
    "extralight": "ExtraLight",
    "extra light": "ExtraLight",
    "ultralight": "UltraLight",
    "ultra light": "UltraLight",
    "light": "Light",
    "regular": "Regular",
    "normal": "Regular",
    "book": "Regular",
    "roman": "Regular",
    "medium": "Medium",
    "semibold": "DemiBold",
    "semi bold": "DemiBold",
    "semi-bold": "DemiBold",
    "demibold": "DemiBold",
    "demi bold": "DemiBold",
    "demi-bold": "DemiBold",
    "bold": "Bold",
    "extrabold": "ExtraBold",
    "extra bold": "ExtraBold",
    "extra-bold": "ExtraBold",
    "ultrabold": "UltraBold",
    "ultra bold": "UltraBold",
    "ultra-bold": "UltraBold",
    "black": "Black",
    "heavy": "Black",
    "italic": "Italic"
};

var WEIGHT_KEYWORDS = [
    "thin", "light", "medium", "bold", "black", "heavy", "regular", "normal", "italic", "roman", "book"
];

function normalizeWeightKey(value) {
    return (value || "").trim().toLowerCase().replace(/[-_]+/g, " ");
}

function isKnownWeightStyle(styleName) {
    const lower = cleanStyleName(styleName).toLowerCase();
    for (let i = 0; i < WEIGHT_KEYWORDS.length; i++) {
        if (lower.indexOf(WEIGHT_KEYWORDS[i]) >= 0) {
            return true;
        }
    }
    return false;
}

function parseWeightTag(value) {
    const raw = (value || "").trim();
    if (!raw) {
        return null;
    }

    if (/^\d{1,4}$/.test(raw)) {
        const weight = Math.max(1, Math.min(1000, parseInt(raw, 10)));
        return {
            weight: weight,
            italic: false,
            styleName: styleFromWeight(weight, false)
        };
    }

    const aliasKey = normalizeWeightKey(raw);
    const aliasStyle = WEIGHT_ALIASES[aliasKey];
    if (aliasStyle) {
        return {
            weight: styleWeight(aliasStyle),
            italic: styleItalic(aliasStyle),
            styleName: aliasStyle
        };
    }

    const styleName = cleanStyleName(raw);
    if (!isKnownWeightStyle(styleName)) {
        return null;
    }

    return {
        weight: styleWeight(styleName),
        italic: styleItalic(styleName),
        styleName: styleName
    };
}

function regularWeightResult() {
    return { weight: 400, italic: false, styleName: "Regular" };
}

function resolvedWeightMatchesRequest(requested, resolvedStyle, resolvedWeight, resolvedItalic) {
    if (resolvedStyle.toLowerCase() === requested.styleName.toLowerCase()) {
        return true;
    }
    if (resolvedWeight === requested.weight && resolvedItalic === requested.italic) {
        return true;
    }
    if (styleWeight(resolvedStyle) === requested.weight && styleItalic(resolvedStyle) === requested.italic) {
        return true;
    }
    return false;
}

function resolveWeightForFamily(family, pointSize, weightValue) {
    const requested = parseWeightTag(weightValue);
    if (!requested || !family) {
        return regularWeightResult();
    }

    const probe = Qt.font({
        family: family,
        pointSize: Math.max(1, pointSize || 12),
        styleName: requested.styleName,
        weight: requested.weight,
        italic: requested.italic
    });

    const resolvedWeight = probe.weight || 400;
    const resolvedItalic = !!probe.italic;
    const resolvedStyle = probe.styleName
        ? cleanStyleName(probe.styleName)
        : styleFromWeight(resolvedWeight, resolvedItalic);

    if (resolvedWeightMatchesRequest(requested, resolvedStyle, resolvedWeight, resolvedItalic)) {
        return {
            weight: resolvedWeight,
            italic: resolvedItalic,
            styleName: resolvedStyle
        };
    }

    return regularWeightResult();
}

function weightSpanStyle(resolved) {
    let css = "font-weight:" + resolved.weight;
    if (resolved.italic) {
        css += ";font-style:italic";
    } else {
        css += ";font-style:normal";
    }
    return css;
}

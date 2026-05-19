.pragma library

var PLASMA = "[center]hh:mm AP\n[size=8]M/d/yyyy[/size][/center]";
var PEAR = "ddd MMM d   hh:mm AP";
var PRESET_IDS = ["plasma", "pear", "custom"];

function template(presetId) {
    return presetId === "pear" ? PEAR : PLASMA;
}

function resolveActiveTemplate(presetId, customFormat) {
    if ((presetId || "plasma") === "custom") {
        return customFormat || PLASMA;
    }
    return template(presetId);
}

function presetIndex(presetId) {
    var index = PRESET_IDS.indexOf(presetId);
    return index >= 0 ? index : 0;
}

function presetIdFromIndex(index) {
    return PRESET_IDS[index] || PRESET_IDS[0];
}

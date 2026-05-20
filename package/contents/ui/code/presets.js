.pragma library

var PLASMA = "[center]hh:mm AP\n[size=8]M/d/yyyy[/size][/center]";
var PEAR = "ddd MMM d   hh:mm AP";
var PRESET_IDS = ["plasma", "pear", "custom"];

var TOOLTIP_DIGITAL_CLOCK = "[center][size=11]dddd, MMMM d, yyyy[/size]\n[b]tz: h:mm:ss AP[/b][/center]";
var TOOLTIP_LONG_DATE = "[center][size=11]dddd, MMMM d, yyyy[/size]\n[b]h:mm:ss AP[/b][/center]";
var TOOLTIP_PRESET_IDS = ["digitalClock", "longDate", "custom"];

function template(presetId) {
    return presetId === "pear" ? PEAR : PLASMA;
}

function tooltipTemplate(presetId) {
    return presetId === "longDate" ? TOOLTIP_LONG_DATE : TOOLTIP_DIGITAL_CLOCK;
}

function resolveActive(presetId, customFormat, defaultPreset, defaultTemplate, templateFn) {
    if ((presetId || defaultPreset) === "custom") {
        return customFormat || defaultTemplate;
    }
    return templateFn(presetId);
}

function resolveActiveTemplate(presetId, customFormat) {
    return resolveActive(presetId, customFormat, "plasma", PLASMA, template);
}

function resolveActiveTooltipTemplate(presetId, customFormat) {
    return resolveActive(presetId, customFormat, "digitalClock", TOOLTIP_DIGITAL_CLOCK, tooltipTemplate);
}

function indexInList(presetId, ids) {
    var index = ids.indexOf(presetId);
    return index >= 0 ? index : 0;
}

function idFromIndex(index, ids) {
    return ids[index] || ids[0];
}

function presetIndex(presetId) {
    return indexInList(presetId, PRESET_IDS);
}

function tooltipPresetIndex(presetId) {
    return indexInList(presetId, TOOLTIP_PRESET_IDS);
}

function presetIdFromIndex(index) {
    return idFromIndex(index, PRESET_IDS);
}

function tooltipPresetIdFromIndex(index) {
    return idFromIndex(index, TOOLTIP_PRESET_IDS);
}

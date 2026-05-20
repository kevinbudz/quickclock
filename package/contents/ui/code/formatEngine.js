.pragma library

function pad2(value) {
    return value < 10 ? "0" + value : "" + value;
}

function hour12(hours24) {
    const h = hours24 % 12;
    return h === 0 ? 12 : h;
}

function tokens(date, use24hFormat, locale, shortFormat, longFormat) {
    const hours24 = date.getHours();
    const minutes = date.getMinutes();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const year = date.getFullYear();
    const h12 = hour12(hours24);

    const use24h = use24hFormat === 2;
    const use12h = use24hFormat === 0;
    const useLocale = use24hFormat === 1;
    const localeUses24h = locale.timeFormat(shortFormat).toLowerCase().indexOf("ap") === -1;

    const show24h = use24h || (useLocale && localeUses24h);
    const ap = hours24 < 12 ? "AM" : "PM";

    return {
        "yyyy": "" + year,
        "yy": pad2(year % 100),
        "MMM": locale.monthName(month - 1, shortFormat),
        "MMMM": locale.monthName(month - 1, longFormat),
        "MM": pad2(month),
        "M": "" + month,
        "ddd": locale.dayName(date.getDay(), shortFormat),
        "dddd": locale.dayName(date.getDay(), longFormat),
        "dd": pad2(day),
        "d": "" + day,
        "HH": pad2(hours24),
        "H": "" + hours24,
        "hh": pad2(show24h ? hours24 : h12),
        "h": "" + (show24h ? hours24 : h12),
        "mm": pad2(minutes),
        "m": "" + minutes,
        "AP": ap,
        "ap": ap.toLowerCase()
    };
}

function expand(template, date, use24hFormat, locale, shortFormat, longFormat) {
    if (!template) {
        return "";
    }

    if (!date || !locale) {
        return template;
    }

    const map = tokens(date, use24hFormat, locale, shortFormat, longFormat);
    const keys = Object.keys(map).sort(function(a, b) {
        if (b.length !== a.length) {
            return b.length - a.length;
        }
        return a < b ? -1 : 1;
    });

    const placeholders = [];
    let result = template;
    for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const placeholder = "\uE000" + i + "\uE001";
        placeholders.push({ placeholder: placeholder, value: map[key] });
        result = result.split(key).join(placeholder);
    }
    for (let j = 0; j < placeholders.length; j++) {
        result = result.split(placeholders[j].placeholder).join(placeholders[j].value);
    }
    return result;
}

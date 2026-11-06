#!/usr/bin/env python3
"""Generates Sources/HolidayKit/Resources/holidays.json from the python-holidays library.

python-holidays (https://github.com/vacanza/holidays, MIT license) computes public holidays for
about 250 countries. This script looks at each country from FIRST_YEAR to LAST_YEAR and turns every
holiday into the most compact rule that reproduces all its dates:

    fixed     same month and day every year
    easter    days from Western Easter Sunday
    orthodox  days from Orthodox Easter Sunday
    weekday   n-th (or last) weekday of a month
    dates     explicit dates (lunar calendars, one-off and irregular holidays), EXPLICIT_FROM..EXPLICIT_TO

Holidays that start or stop being observed get "from"/"until" years. Names come in the country's
default language and, when the library has it, in English.

Usage (in a virtual environment):
    python3 -m venv env && env/bin/pip install holidays
    env/bin/python -I Scripts/generate_catalog.py
"""

import datetime
import json
import re
import sys
import unicodedata
from collections import defaultdict
from pathlib import Path

import holidays

FIRST_YEAR = 2000
LAST_YEAR = 2070
EXPLICIT_FROM = 2015
EXPLICIT_TO = 2065
# Countries curated by hand in HolidayCatalog.swift (with six-language names); the generated data
# is not used for them.
CURATED = {"BR", "PT", "US", "CA", "GB", "MX", "ES", "CO", "FR", "DE", "IT"}
NOISE = re.compile(r"\s*[\(\[]?\*?\s*(estimated|estimado|estimada|observed|observado|observada)\s*[\)\]]?\s*$", re.I)


def western_easter(year):
    a, b, c = year % 19, year // 100, year % 100
    d, e = b // 4, b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c // 4, c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    month = (h + l - 7 * m + 114) // 31
    day = (h + l - 7 * m + 114) % 31 + 1
    return datetime.date(year, month, day)


def orthodox_easter(year):
    a, b, c = year % 4, year % 7, year % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    month = (d + e + 114) // 31
    day = (d + e + 114) % 31 + 1
    julian = datetime.date(year, month, day)
    return julian + datetime.timedelta(days=13)  # valid 1900-2099


def weekday_rule(dates):
    """n-th weekday of the month (1-based), or -1 for the last, when every date agrees."""
    months = {d.month for d in dates}
    weekdays = {d.isoweekday() % 7 + 1 for d in dates}  # 1 = Sunday ... 7 = Saturday
    if len(months) != 1 or len(weekdays) != 1:
        return None
    ordinals = {(d.day - 1) // 7 + 1 for d in dates}
    if len(ordinals) == 1:
        return (months.pop(), weekdays.pop(), ordinals.pop())
    lasts = {(d + datetime.timedelta(days=7)).month != d.month for d in dates}
    if lasts == {True}:
        return (months.pop(), weekdays.pop(), -1)
    return None


def infer_rule(series):
    """series: {year: date}. Returns a rule string."""
    dates = list(series.values())
    if len({(d.month, d.day) for d in dates}) == 1:
        return "fixed:%d-%d" % (dates[0].month, dates[0].day)
    offsets = {(d - western_easter(d.year)).days for d in dates}
    if len(offsets) == 1:
        return "easter:%d" % offsets.pop()
    offsets = {(d - orthodox_easter(d.year)).days for d in dates}
    if len(offsets) == 1:
        return "orthodox:%d" % offsets.pop()
    rule = weekday_rule(dates)
    if rule:
        return "weekday:%d,%d,%d" % rule
    return None


def segment_rules(per_year, years):
    """Rules (one per day of the holiday) that fit every year in `years`, or None."""
    counts = {len(per_year[year]) for year in years}
    if len(counts) != 1:
        return None
    rules = []
    for index in range(counts.pop()):
        rule = infer_rule({year: sorted(per_year[year])[index] for year in years})
        if rule is None:
            return None
        rules.append(rule)
    return rules


def segment(per_year, max_segments=4, min_last=10):
    """Splits the years into the fewest runs that each follow fixed rules (a holiday that moved
    by law, or a one-off year). Returns [(first, last, rules)] or None for irregular holidays."""
    years = sorted(per_year)
    segments = []
    start = 0
    while start < len(years):
        end = start
        rules = segment_rules(per_year, years[start:start + 1])
        while end + 1 < len(years) and years[end + 1] == years[end] + 1:
            candidate = segment_rules(per_year, years[start:end + 2])
            if candidate is None:
                break
            rules = candidate
            end += 1
        segments.append((years[start], years[end], rules))
        start = end + 1
    if len(segments) > max_segments:
        return None
    first, last, _ = segments[-1]
    if last == LAST_YEAR and last - first + 1 < min_last:
        return None
    # Short runs are only kept inside the explicit window; older ones do not matter.
    return [s for s in segments if s[1] >= EXPLICIT_FROM or s[1] - s[0] >= 1]


def clean(name):
    return NOISE.sub("", name).strip()


def slug(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_") or "holiday"


def english_language(country):
    languages = holidays.list_localized_countries().get(country, [])
    for preferred in ("en_US", "en_GB", "en_IN", "en_CA", "en_AU", "en_NZ", "en_PH"):
        if preferred in languages:
            return preferred
    return next((language for language in languages if language.startswith("en")), None)


def names_by_date(country, language, years):
    # Observed (substitute) days are left out: BusinessDayCalendar moves dates by itself.
    try:
        calendar = holidays.country_holidays(country, years=years, language=language, observed=False)
    except Exception:  # noqa: BLE001 - some countries reject explicit languages
        calendar = holidays.country_holidays(country, years=years, observed=False)
    result = {}
    for date, names in calendar.items():
        result[date] = [clean(part) for part in names.split("; ")]
    return result


def generate_country(country):
    years = range(FIRST_YEAR, LAST_YEAR + 1)
    entity = holidays.country_holidays(country)
    default_language = getattr(entity, "default_language", None) or "en"
    native = names_by_date(country, default_language, years)
    english_code = english_language(country)
    english = names_by_date(country, english_code, years) if english_code else {}

    # name -> year -> [dates]; and the English name of each native name
    occurrences = defaultdict(lambda: defaultdict(list))
    english_names = {}
    for date in sorted(native):
        native_names = native[date]
        english_list = english.get(date, [])
        for index, name in enumerate(native_names):
            occurrences[name][date.year].append(date)
            if index < len(english_list) and name not in english_names:
                english_names[name] = english_list[index]

    entries = []
    for name, per_year in occurrences.items():
        english_name = english_names.get(name)
        key_base = "%s.%s" % (country.lower(), slug(english_name or name))
        segments = segment(per_year)
        if segments is not None:
            for first, last, rules in segments:
                start = first if first > FIRST_YEAR else None
                end = last if last < LAST_YEAR else None
                for index, rule in enumerate(rules):
                    entries.append(entry(key_base, index, len(rules), name, english_name, rule, start, end))
            continue
        dates = [d for year in sorted(per_year) for d in per_year[year] if EXPLICIT_FROM <= year <= EXPLICIT_TO]
        if dates:
            rule = "dates:" + ",".join(d.strftime("%Y%m%d") for d in sorted(dates))
            entries.append(entry(key_base, 0, 1, name, english_name, rule, None, None))
    # The same holiday keeps its key across rule changes (one entry per run of years).
    return {"language": default_language.split("_")[0], "holidays": entries}


# Holidays shared by many countries get the shared key of HolidayNames.swift (and its six
# languages) when the rule and the English name agree.
SHARED = {
    "fixed:1-1": ("new_year", "new year"),
    "fixed:1-6": ("epiphany", "epiphany"),
    "easter:-3": ("maundy_thursday", "thursday"),
    "easter:-2": ("good_friday", "good friday"),
    "easter:0": ("easter_sunday", "easter"),
    "easter:1": ("easter_monday", "easter monday"),
    "fixed:5-1": ("labour_day", "labo"),
    "easter:39": ("ascension", "ascension"),
    "easter:49": ("whit_sunday", "whit"),
    "easter:50": ("whit_monday", "whit monday"),
    "easter:60": ("corpus_christi", "corpus christi"),
    "fixed:8-15": ("assumption", "assumption"),
    "fixed:11-1": ("all_saints", "all saints"),
    "fixed:11-2": ("all_souls", "all souls"),
    "fixed:12-8": ("immaculate_conception", "immaculate conception"),
    "fixed:12-24": ("christmas_eve", "christmas eve"),
    "fixed:12-25": ("christmas", "christmas"),
    "fixed:12-26": ("boxing_day", "boxing day"),
    "fixed:12-31": ("new_years_eve", "new year"),
}


def entry(key_base, index, count, name, english_name, rule, start, end):
    key = key_base if count == 1 else "%s_%d" % (key_base, index + 1)
    shared = SHARED.get(rule)
    if shared and shared[1] in (english_name or name).lower() and not (shared[0] == "boxing_day" and "second" in (english_name or "").lower()):
        key = shared[0]
    item = {"key": key, "name": name, "rule": rule}
    if english_name and english_name != name:
        item["en"] = english_name
    if start:
        item["from"] = start
    if end:
        item["until"] = end
    return item


def main():
    countries = sorted(code for code in holidays.list_supported_countries() if len(code) == 2)
    catalog = {}
    for country in countries:
        if country in CURATED:
            continue
        try:
            data = generate_country(country)
        except Exception as error:  # noqa: BLE001
            print("skip %s: %s" % (country, error), file=sys.stderr)
            continue
        if data["holidays"]:
            catalog[country] = data
    output = Path(__file__).resolve().parent.parent / "Sources/HolidayKit/Resources/holidays.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    meta = {"source": "python-holidays %s (MIT)" % holidays.__version__, "years": [FIRST_YEAR, LAST_YEAR],
            "explicit": [EXPLICIT_FROM, EXPLICIT_TO]}
    output.write_text(json.dumps({"meta": meta, "countries": catalog}, ensure_ascii=False, separators=(",", ":")))
    total = sum(len(country["holidays"]) for country in catalog.values())
    explicit = sum(1 for country in catalog.values() for item in country["holidays"] if item["rule"].startswith("dates:"))
    print("countries %d, holidays %d, explicit %d, %d KB" % (len(catalog), total, explicit, output.stat().st_size // 1024))


if __name__ == "__main__":
    main()

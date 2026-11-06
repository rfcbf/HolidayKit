# HolidayKit

National holidays for every country in ISO 3166-1, with names in the country's language and in
English (six languages for the most common holidays), and business-day shifting for due dates: a
date on a holiday — and, if enabled, on a weekend — moves to the next business day, the way bank
slips and card statements work in Brazil.

Pure Swift, no dependencies. iOS 17, macOS 14, watchOS 10, tvOS 17, visionOS 1.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/rfcbf/HolidayKit.git", from: "2.0.0")
```

or in Xcode: File › Add Package Dependencies… and paste the URL.

## Usage

```swift
import HolidayKit

let calendar = BusinessDayCalendar(countryCode: "BR")
calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 15)) // 2026-11-16 (Sunday + holiday)
calendar.isHoliday(CalendarDay(2026, 11, 20))                   // true
calendar.holidayName(on: CalendarDay(2026, 11, 20))             // "Dia da Consciência Negra" (pt)
calendar.holidayName(on: CalendarDay(2026, 11, 20),
                     locale: Locale(identifier: "en"))          // "Black Consciousness Day"
calendar.holidays(year: 2026, month: 11)                        // [date: name] for a calendar

// Holidays only, weekends stay as they are
BusinessDayCalendar(countryCode: "PT", shiftsWeekends: false)

// The person's own holidays on top of the national ones
BusinessDayCalendar(
    countryCode: "BR",
    customHolidays: [CalendarDay(2026, 11, 30): "Ponte"],
    recurringHolidays: [.init(month: 4, day: 21, name: "Aniversário de Brasília")]
)

HolidayCatalog.sortedCountries()                                // every country, by name
HolidayCatalog.search("japao", locale: Locale(identifier: "pt_BR")) // [JP], for a search field
HolidayCatalog.country("AQ")?.hasHolidays                       // false: listed, no holidays
HolidayCatalog.country("BR")?.flag                              // "🇧🇷"
HolidayCatalog.country("BR")?.localizedName()                   // "Brasil" / "Brazil"
```

`CalendarDay` is a plain civil date (year, month, day) with no time or time zone, so a holiday
never moves a day because of daylight saving. Convert with `CalendarDay(date)` and `day.date()`.

## Countries

`HolidayCatalog.countries` lists every ISO 3166-1 country and territory (about 250).

- **Curated by hand** (names in six languages): Brazil, Portugal, United States, Canada, United
  Kingdom (England and Wales), Mexico, Spain, Colombia (Ley Emiliani), France, Germany and Italy.
  Brazil includes Carnival (Monday and Tuesday) and Corpus Christi.
- **Generated** (about 225 more): national holidays from
  [python-holidays](https://github.com/vacanza/holidays) (MIT), turned into rules by
  `Scripts/generate_catalog.py` and shipped in `Resources/holidays.json`. Holidays of lunar
  calendars (Eid, Lunar New Year, Diwali, Vesak) are explicit dates from 2015 to 2065.
- A few territories have no holidays (`hasHolidays == false`) and are still listed, so a picker
  can show them.

National holidays only. State, regional and city holidays are left to the app, which can add the
person's own on top (`customHolidays`, `recurringHolidays`). Observed (substitute) days are not
included: `BusinessDayCalendar` already moves a date that falls on a weekend.

### Keeping the data up to date

Governments add, remove and move holidays. Once a month the `Update holidays` workflow installs
the latest python-holidays, regenerates `holidays.json`, runs the tests and opens a pull request
when anything changed. After review it is merged and released as a new minor version; apps get it
by updating the package. To regenerate by hand:

```sh
python3 -m venv env && env/bin/pip install holidays
env/bin/python -I Scripts/generate_catalog.py
```

## Languages

Each holiday has a stable `key` ("christmas", "br.tiradentes", "jp.marine_day"), its
`officialName` in the country's language and, for generated countries, its `englishName`.
Holidays shared by many countries ("new_year", "christmas", "good_friday", "labour_day"...) and
every holiday of the curated countries have translations in English, Portuguese, Spanish, French,
German and Italian. `localizedName(locale)` returns the official name when the locale speaks the
country's language, then the translation, then English, then the official name.

## Rules

| Rule | Example |
|---|---|
| `.fixed(month:day:)` | Christmas |
| `.easter(offset:)` | Good Friday (-2), Corpus Christi (+60) |
| `.weekday(month:weekday:ordinal:)` | Thanksgiving (4th Thursday), Memorial Day (last Monday) |
| `.nextMonday(month:day:)` | Colombia's Ley Emiliani |
| `.mondayBefore(month:day:)` | Canada's Victoria Day |
| `.orthodoxEaster(offset:)` | Orthodox Good Friday (-2), Easter Monday (+1) |
| `.dates([CalendarDay])` | Lunar and irregular holidays (explicit dates) |

A holiday that moved by law has one entry per period, with `firstYear` and `lastYear`.

## Migrating from 1.x

- `HolidayRule.date(in:)` now returns an optional; use `dates(in:)` for every date of a year.
- `HolidayCatalog.countries` lists every country; check `hasHolidays` where it matters.
- `HolidayCatalog.curated` has the eleven hand-made countries of 1.x.

## Contributing

Fixes to generated countries are best sent to python-holidays, so every project gets them; the
next monthly update brings them here. For the curated countries, edit `HolidayCatalog`, add any
new key to `HolidayNames` in all six languages and add a test for a known year. Please cite an
official source in the pull request.

## License

MIT. See [LICENSE](LICENSE). The generated data comes from python-holidays, also MIT; see
[NOTICE](NOTICE).

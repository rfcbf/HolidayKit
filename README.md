# HolidayKit

National holidays by country, calculated by rules (no per-year tables), with names in six
languages, and business-day shifting for due dates: a date on a holiday — and, if enabled, on a
weekend — moves to the next business day, the way bank slips and card statements work in Brazil.

Pure Swift, no dependencies, no resources. iOS 17, macOS 14, watchOS 10, tvOS 17, visionOS 1.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/rfcbf/HolidayKit.git", from: "1.0.0")
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

HolidayCatalog.sortedCountries()                                // for a country picker
HolidayCatalog.country("BR")?.flag                              // "🇧🇷"
HolidayCatalog.country("BR")?.localizedName()                   // "Brasil" / "Brazil"
```

`CalendarDay` is a plain civil date (year, month, day) with no time or time zone, so a holiday
never moves a day because of daylight saving. Convert with `CalendarDay(date)` and `day.date()`.

## Countries

| Code | Country | Notes |
|---|---|---|
| BR | Brazil | National holidays, Carnival (Monday and Tuesday) and Corpus Christi |
| PT | Portugal | |
| US | United States | Federal holidays |
| CA | Canada | Federal holidays |
| GB | United Kingdom | England and Wales bank holidays |
| MX | Mexico | |
| ES | Spain | National holidays |
| CO | Colombia | Ley Emiliani (moved to Monday) |
| FR | France | |
| DE | Germany | Nationwide holidays |
| IT | Italy | |

National holidays only. State, regional and city holidays are left to the app, which can add the
person's own on top (`customHolidays`, `recurringHolidays`).

## Languages

Each holiday has a stable `key` ("christmas", "br.tiradentes"), its `officialName` in the
country's language, and translations in English, Portuguese, Spanish, French, German and Italian.
`localizedName(locale)` returns the official name when the locale speaks the country's language,
the translation otherwise, and English for any other language.

## Rules

| Rule | Example |
|---|---|
| `.fixed(month:day:)` | Christmas |
| `.easter(offset:)` | Good Friday (-2), Corpus Christi (+60) |
| `.weekday(month:weekday:ordinal:)` | Thanksgiving (4th Thursday), Memorial Day (last Monday) |
| `.nextMonday(month:day:)` | Colombia's Ley Emiliani |
| `.mondayBefore(month:day:)` | Canada's Victoria Day |

## Contributing

To add a country, add a `HolidayCountry` to `HolidayCatalog` with keys for its holidays, add any
new key to `HolidayNames` in all six languages, and add a test for a known year. The tests check
that every key has every language. Corrections to dates or names are welcome — please cite an
official source in the pull request.

## License

MIT. See [LICENSE](LICENSE).

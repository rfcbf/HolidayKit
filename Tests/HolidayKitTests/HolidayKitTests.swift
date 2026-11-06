import Foundation
@testable import HolidayKit
import Testing

@Suite("CalendarDay")
struct CalendarDayTests {
    @Test("Weekday, adding days across months and years, and clamping")
    func basics() {
        #expect(CalendarDay(2026, 11, 5).weekday == 5) // Thursday
        #expect(CalendarDay(2026, 11, 15).isWeekend)
        #expect(CalendarDay(2026, 12, 30).adding(days: 3) == CalendarDay(2027, 1, 2))
        #expect(CalendarDay(2028, 3, 1).adding(days: -1) == CalendarDay(2028, 2, 29))
        #expect(CalendarDay(2027, 2, 31) == CalendarDay(2027, 2, 28))
        #expect(CalendarDay(2026, 13, 1) == CalendarDay(2027, 1, 1))
        #expect(CalendarDay(2026, 11, 5).days(until: CalendarDay(2026, 11, 10)) == 5)
    }

    @Test("Round trip through Date keeps the day")
    func date() {
        let day = CalendarDay(2026, 3, 8)
        #expect(CalendarDay(day.date()) == day)
    }
}

@Suite("Easter and rules")
struct RuleTests {
    @Test("Easter Sunday of known years")
    func easter() {
        #expect(Easter.sunday(in: 2024) == CalendarDay(2024, 3, 31))
        #expect(Easter.sunday(in: 2025) == CalendarDay(2025, 4, 20))
        #expect(Easter.sunday(in: 2026) == CalendarDay(2026, 4, 5))
        #expect(Easter.sunday(in: 2027) == CalendarDay(2027, 3, 28))
        #expect(Easter.sunday(in: 2038) == CalendarDay(2038, 4, 25))
    }

    @Test("Weekday rules: n-th and last")
    func weekday() {
        #expect(HolidayRule.weekday(month: 11, weekday: 5, ordinal: 4).date(in: 2026) == CalendarDay(2026, 11, 26))
        #expect(HolidayRule.weekday(month: 5, weekday: 2, ordinal: -1).date(in: 2026) == CalendarDay(2026, 5, 25))
        #expect(HolidayRule.weekday(month: 9, weekday: 2, ordinal: 1).date(in: 2026) == CalendarDay(2026, 9, 7))
    }

    @Test("Next Monday (Ley Emiliani) and Monday before (Victoria Day)")
    func mondays() {
        #expect(HolidayRule.nextMonday(month: 1, day: 6).date(in: 2026) == CalendarDay(2026, 1, 12))
        #expect(HolidayRule.nextMonday(month: 10, day: 12).date(in: 2026) == CalendarDay(2026, 10, 12))
        #expect(HolidayRule.mondayBefore(month: 5, day: 25).date(in: 2026) == CalendarDay(2026, 5, 18))
        #expect(HolidayRule.mondayBefore(month: 5, day: 25).date(in: 2027) == CalendarDay(2027, 5, 24))
    }
}

@Suite("Catalog")
struct CatalogTests {
    @Test("Brazil 2026: Carnival, Good Friday, Corpus Christi and fixed holidays")
    func brazil() throws {
        let days = try #require(HolidayCatalog.country("br")).holidayNames(in: 2026, locale: Locale(identifier: "pt_BR"))
        #expect(days[CalendarDay(2026, 2, 16)] == "Carnaval")
        #expect(days[CalendarDay(2026, 2, 17)] == "Carnaval")
        #expect(days[CalendarDay(2026, 4, 3)] == "Sexta-feira Santa")
        #expect(days[CalendarDay(2026, 6, 4)] == "Corpus Christi")
        #expect(days[CalendarDay(2026, 11, 20)] == "Dia da Consciência Negra")
        #expect(days.count == 13)
    }

    @Test("Every ISO country is listed once, with a two-letter code and a flag")
    func catalog() {
        let countries = HolidayCatalog.countries
        #expect(countries.count >= 245)
        #expect(countries.allSatisfy { $0.code.count == 2 && $0.flag.unicodeScalars.count == 2 })
        #expect(Set(countries.map(\.code)).count == countries.count)
        #expect(countries.filter(\.hasHolidays).count >= 230)
        #expect(HolidayCatalog.country("EU") == nil)
        #expect(HolidayCatalog.country("BR")?.flag == "🇧🇷")
        #expect(HolidayCatalog.country("BR")?.localizedName(Locale(identifier: "pt_BR")) == "Brasil")
        #expect(HolidayCatalog.sortedCountries(Locale(identifier: "pt_BR")).first?.code == "AF")
        #expect(HolidayCatalog.dataSource.hasPrefix("python-holidays"))
    }

    @Test("Search by name in the locale, by English name and by code, ignoring accents")
    func search() {
        let portuguese = Locale(identifier: "pt_BR")
        #expect(HolidayCatalog.search("japao", locale: portuguese).map(\.code) == ["JP"])
        #expect(HolidayCatalog.search("Japan", locale: portuguese).map(\.code) == ["JP"])
        #expect(HolidayCatalog.search("jp", locale: portuguese).map(\.code).contains("JP"))
        #expect(HolidayCatalog.search("", locale: portuguese).count == HolidayCatalog.countries.count)
        #expect(HolidayCatalog.search("zzzz", locale: portuguese).isEmpty)
    }

    @Test("Every entry of the generated file becomes a holiday")
    func generated() throws {
        let url = try #require(Bundle.module.url(forResource: "holidays", withExtension: "json"))
        let json = try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let countries = try #require(json["countries"] as? [String: [String: Any]])
        for (code, country) in countries {
            let entries = (country["holidays"] as? [Any])?.count ?? 0
            #expect(HolidayCatalog.country(code)?.holidays.count == entries, "\(code)")
        }
    }

    @Test("Japan: weekday rules, a holiday that moved by law and one that skipped a year")
    func japan() throws {
        let japan = try #require(HolidayCatalog.country("JP"))
        let english = Locale(identifier: "en")
        let days2026 = japan.holidayNames(in: 2026, locale: english)
        #expect(days2026[CalendarDay(2026, 1, 12)] == "Coming of Age Day") // 2nd Monday
        #expect(days2026[CalendarDay(2026, 2, 23)] == "Emperor's Birthday")
        #expect(days2026[CalendarDay(2026, 7, 20)] == "Marine Day") // 3rd Monday
        #expect(japan.holidayNames(in: 2018, locale: english)[CalendarDay(2018, 12, 23)] == "Emperor's Birthday")
        #expect(!japan.holidayNames(in: 2019, locale: english).values.contains("Emperor's Birthday"))
        #expect(japan.holidayNames(in: 2026, locale: Locale(identifier: "ja"))[CalendarDay(2026, 1, 1)] == "元日")
        #expect(days2026[CalendarDay(2026, 1, 1)] == "New Year's Day")
        #expect(japan.holidayNames(in: 2026, locale: Locale(identifier: "pt_BR"))[CalendarDay(2026, 1, 1)] == "Ano-Novo")
    }

    @Test("Orthodox Easter and lunar holidays")
    func otherCalendars() throws {
        #expect(Easter.orthodoxSunday(in: 2025) == CalendarDay(2025, 4, 20))
        #expect(Easter.orthodoxSunday(in: 2026) == CalendarDay(2026, 4, 12))
        #expect(Easter.orthodoxSunday(in: 2027) == CalendarDay(2027, 5, 2))
        let greece = try #require(HolidayCatalog.country("GR")).holidays(in: 2026)
        #expect(greece[CalendarDay(2026, 4, 13)] != nil) // Easter Monday (Orthodox)
        let china = try #require(HolidayCatalog.country("CN")).holidays(in: 2026)
        #expect(china[CalendarDay(2026, 2, 17)] != nil) // Lunar New Year
        let india = try #require(HolidayCatalog.country("IN")).holidays(in: 2026)
        #expect(india[CalendarDay(2026, 1, 26)] != nil) // Republic Day
    }

    @Test("Explicit dates only cover their years")
    func explicitDates() {
        let rule = HolidayRule.dates([CalendarDay(2026, 3, 20), CalendarDay(2027, 3, 10)])
        #expect(rule.dates(in: 2026) == [CalendarDay(2026, 3, 20)])
        #expect(rule.dates(in: 2030).isEmpty)
        #expect(HolidayRule(encoded: "dates:20260320,20270310") == rule)
        #expect(HolidayRule(encoded: "weekday:7,2,3") == .weekday(month: 7, weekday: 2, ordinal: 3))
        #expect(HolidayRule(encoded: "orthodox:-2") == .orthodoxEaster(offset: -2))
        #expect(HolidayRule(encoded: "lunar:1") == nil)
    }
}

@Suite("Languages")
struct LanguageTests {
    @Test("Official name in the country's language; translations in the others")
    func names() throws {
        let brazil = try #require(HolidayCatalog.country("BR"))
        let newYear = try #require(brazil.holidays.first { $0.key == "new_year" })
        #expect(newYear.localizedName(Locale(identifier: "pt_BR")) == "Confraternização Universal")
        #expect(newYear.localizedName(Locale(identifier: "en_US")) == "New Year's Day")
        #expect(newYear.localizedName(Locale(identifier: "es_MX")) == "Año Nuevo")
        #expect(newYear.localizedName(Locale(identifier: "de_DE")) == "Neujahr")
        // Unsupported language falls back to English.
        #expect(newYear.localizedName(Locale(identifier: "ja_JP")) == "New Year's Day")

        let thanksgiving = try #require(HolidayCatalog.country("US")?.holidays.first { $0.key == "thanksgiving" })
        #expect(thanksgiving.localizedName(Locale(identifier: "pt_BR")) == "Dia de Ação de Graças")
        #expect(thanksgiving.localizedName(Locale(identifier: "en_GB")) == "Thanksgiving Day")
    }

    @Test("Every holiday key of the curated countries has every supported language")
    func coverage() {
        for country in HolidayCatalog.curated {
            for holiday in country.holidays {
                let names = HolidayNames.table[holiday.key]
                #expect(names != nil, "missing key \(holiday.key)")
                for language in Holiday.supportedLanguages {
                    #expect(names?[language] != nil, "\(holiday.key) has no \(language)")
                }
            }
        }
    }

    @Test("Calendar names follow the locale; custom names stay as typed")
    func calendar() {
        let calendar = BusinessDayCalendar(countryCode: "BR", customHolidays: [CalendarDay(2026, 11, 30): "Ponte"])
        #expect(calendar.holidayName(on: CalendarDay(2026, 11, 15), locale: Locale(identifier: "en")) == "Proclamation of the Republic")
        #expect(calendar.holidayName(on: CalendarDay(2026, 11, 15), locale: Locale(identifier: "pt_BR")) == "Proclamação da República")
        #expect(calendar.holidayName(on: CalendarDay(2026, 11, 30), locale: Locale(identifier: "en")) == "Ponte")
    }
}

@Suite("BusinessDayCalendar")
struct BusinessDayTests {
    @Test("Holiday or weekend moves to the next business day")
    func shift() {
        let calendar = BusinessDayCalendar(countryCode: "BR")
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 15)) == CalendarDay(2026, 11, 16))
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 20)) == CalendarDay(2026, 11, 23))
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 2, 16)) == CalendarDay(2026, 2, 18))
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 10)) == CalendarDay(2026, 11, 10))
    }

    @Test("Holidays only: weekends stay; none changes nothing")
    func holidaysOnly() {
        let calendar = BusinessDayCalendar(countryCode: "BR", shiftsWeekends: false)
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 21)) == CalendarDay(2026, 11, 21))
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 20)) == CalendarDay(2026, 11, 21))
        #expect(BusinessDayCalendar.none.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 15)) == CalendarDay(2026, 11, 15))
    }

    @Test("Custom holidays: exact date and every year")
    func custom() {
        let calendar = BusinessDayCalendar(
            countryCode: "BR",
            customHolidays: [CalendarDay(2026, 11, 30): "Bridge"],
            recurringHolidays: [.init(month: 4, day: 21, name: "Brasília's anniversary")]
        )
        #expect(calendar.holidayName(on: CalendarDay(2026, 11, 30)) == "Bridge")
        #expect(calendar.holidayName(on: CalendarDay(2030, 4, 21)) == "Brasília's anniversary")
        #expect(calendar.isHoliday(CalendarDay(2026, 11, 2)))
        #expect(calendar.nextBusinessDay(onOrAfter: CalendarDay(2026, 11, 30)) == CalendarDay(2026, 12, 1))
        #expect(calendar.holidays(year: 2026, month: 11).count == 4)
    }
}

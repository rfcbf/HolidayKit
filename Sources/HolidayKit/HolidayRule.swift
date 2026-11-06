import Foundation

/// How to find a holiday's date in a given year. Rules instead of per-year tables, so the catalog
/// works for any year.
public enum HolidayRule: Equatable, Hashable, Sendable {
    /// Same day every year (December 25).
    case fixed(month: Int, day: Int)
    /// Days from Easter Sunday (Good Friday = -2, Corpus Christi = +60).
    case easter(offset: Int)
    /// Days from Orthodox Easter Sunday (Julian computus, in the Gregorian calendar).
    case orthodoxEaster(offset: Int)
    /// The n-th weekday of a month (weekday 1 = Sunday ... 7 = Saturday); ordinal -1 = the last.
    case weekday(month: Int, weekday: Int, ordinal: Int)
    /// Moved to the next Monday when it does not fall on a Monday (Colombia's Ley Emiliani).
    case nextMonday(month: Int, day: Int)
    /// The Monday strictly before a date (Canada's Victoria Day: the Monday before May 25).
    case mondayBefore(month: Int, day: Int)
    /// Explicit dates, for holidays of lunar calendars (Eid, Lunar New Year, Diwali) and other
    /// irregular ones. Only covers the years the catalog was generated for.
    case dates([CalendarDay])

    /// The holiday's dates in `year`: one for every rule except `.dates`, which may have none or
    /// several (an Islamic holiday can happen twice in a Gregorian year).
    public func dates(in year: Int) -> [CalendarDay] {
        if case let .dates(list) = self {
            return list.filter { $0.year == year }
        }
        return [computedDate(in: year)]
    }

    /// The first date in `year`, or `nil` when an explicit list has none.
    public func date(in year: Int) -> CalendarDay? {
        dates(in: year).first
    }

    private func computedDate(in year: Int) -> CalendarDay {
        switch self {
        case let .fixed(month, day):
            return CalendarDay(year, month, day)
        case let .easter(offset):
            return Easter.sunday(in: year).adding(days: offset)
        case let .orthodoxEaster(offset):
            return Easter.orthodoxSunday(in: year).adding(days: offset)
        case let .weekday(month, weekday, ordinal):
            if ordinal > 0 {
                let first = CalendarDay(year, month, 1)
                let ahead = (weekday - first.weekday + 7) % 7
                return first.adding(days: ahead + 7 * (ordinal - 1))
            }
            let last = CalendarDay(year, month, CalendarDay.daysInMonth(year: year, month: month))
            let back = (last.weekday - weekday + 7) % 7
            return last.adding(days: -back)
        case let .nextMonday(month, day):
            let date = CalendarDay(year, month, day)
            return date.adding(days: (2 - date.weekday + 7) % 7)
        case let .mondayBefore(month, day):
            let date = CalendarDay(year, month, day)
            let back = (date.weekday - 2 + 7) % 7
            return date.adding(days: -(back == 0 ? 7 : back))
        case let .dates(list):
            return list.first ?? CalendarDay(year, 1, 1)
        }
    }
}

public enum Easter {
    /// Easter Sunday in the Gregorian calendar (Meeus/Jones/Butcher algorithm).
    public static func sunday(in year: Int) -> CalendarDay {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = (h + l - 7 * m + 114) % 31 + 1
        return CalendarDay(year, month, day)
    }

    /// Orthodox Easter Sunday in the Gregorian calendar (Meeus' Julian algorithm plus the 13-day
    /// difference between the calendars, valid from 1900 to 2099).
    public static func orthodoxSunday(in year: Int) -> CalendarDay {
        let a = year % 4
        let b = year % 7
        let c = year % 19
        let d = (19 * c + 15) % 30
        let e = (2 * a + 4 * b - d + 34) % 7
        let month = (d + e + 114) / 31
        let day = (d + e + 114) % 31 + 1
        return CalendarDay(year, month, day).adding(days: 13)
    }
}

/// A national holiday: a stable key (for translations and storage), its official name in the
/// country's language and the rule for its date.
public struct Holiday: Identifiable, Equatable, Hashable, Sendable {
    /// Stable key, such as "christmas" or "br.tiradentes".
    public let key: String
    /// The official name, in the country's own language ("Confraternização Universal").
    public let officialName: String
    public let rule: HolidayRule
    /// The English name, when the official one is in another language.
    public let englishName: String?
    /// First and last years the holiday is observed (`nil`: no limit). A holiday that moved by
    /// law has one entry per period.
    public let firstYear: Int?
    public let lastYear: Int?
    /// Language of `officialName` (ISO 639-1), set by the country.
    public internal(set) var officialLanguage = "en"

    public var id: String {
        "\(key)#\(firstYear ?? 0)"
    }

    public init(
        _ key: String,
        _ officialName: String,
        _ rule: HolidayRule,
        englishName: String? = nil,
        firstYear: Int? = nil,
        lastYear: Int? = nil
    ) {
        self.key = key
        self.officialName = officialName
        self.rule = rule
        self.englishName = englishName
        self.firstYear = firstYear
        self.lastYear = lastYear
    }

    /// Whether the holiday exists in `year`.
    public func isObserved(in year: Int) -> Bool {
        (firstYear.map { year >= $0 } ?? true) && (lastYear.map { year <= $0 } ?? true)
    }

    /// The holiday's dates in `year` (none outside its years).
    public func dates(in year: Int) -> [CalendarDay] {
        isObserved(in: year) ? rule.dates(in: year) : []
    }

    /// The name in `locale`'s language: the official name when it is the country's language,
    /// then the translation table, then English, then the official name.
    public func localizedName(_ locale: Locale = .current) -> String {
        let language = locale.language.languageCode?.identifier ?? "en"
        if language == officialLanguage {
            return officialName
        }
        if let translated = HolidayNames.name(key, language: language, fallback: false) {
            return translated
        }
        if language == "en", let englishName {
            return englishName
        }
        return HolidayNames.name(key, language: "en", fallback: false) ?? englishName ?? officialName
    }

    /// Languages with translated holiday names.
    public static var supportedLanguages: [String] {
        HolidayNames.languages
    }
}

import Foundation

/// How to find a holiday's date in a given year. Rules instead of per-year tables, so the catalog
/// works for any year.
public enum HolidayRule: Equatable, Hashable, Sendable {
    /// Same day every year (December 25).
    case fixed(month: Int, day: Int)
    /// Days from Easter Sunday (Good Friday = -2, Corpus Christi = +60).
    case easter(offset: Int)
    /// The n-th weekday of a month (weekday 1 = Sunday ... 7 = Saturday); ordinal -1 = the last.
    case weekday(month: Int, weekday: Int, ordinal: Int)
    /// Moved to the next Monday when it does not fall on a Monday (Colombia's Ley Emiliani).
    case nextMonday(month: Int, day: Int)
    /// The Monday strictly before a date (Canada's Victoria Day: the Monday before May 25).
    case mondayBefore(month: Int, day: Int)

    public func date(in year: Int) -> CalendarDay {
        switch self {
        case let .fixed(month, day):
            return CalendarDay(year, month, day)
        case let .easter(offset):
            return Easter.sunday(in: year).adding(days: offset)
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
}

/// A national holiday: a stable key (for translations and storage), its official name in the
/// country's language and the rule for its date.
public struct Holiday: Identifiable, Equatable, Hashable, Sendable {
    /// Stable key, such as "christmas" or "br.tiradentes".
    public let key: String
    /// The official name, in the country's own language ("Confraternização Universal").
    public let officialName: String
    public let rule: HolidayRule
    /// Language of `officialName` (ISO 639-1), set by the country.
    public internal(set) var officialLanguage = "en"

    public var id: String {
        key
    }

    public init(_ key: String, _ officialName: String, _ rule: HolidayRule) {
        self.key = key
        self.officialName = officialName
        self.rule = rule
    }

    /// The name in `locale`'s language: the official name when it is the country's language,
    /// otherwise the translation (English as the fallback).
    public func localizedName(_ locale: Locale = .current) -> String {
        let language = locale.language.languageCode?.identifier ?? "en"
        if language == officialLanguage {
            return officialName
        }
        return HolidayNames.name(key, language: language) ?? officialName
    }

    /// Languages with translated holiday names.
    public static var supportedLanguages: [String] {
        HolidayNames.languages
    }
}

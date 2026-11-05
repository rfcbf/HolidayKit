import Foundation

/// A civil date (year, month, day) with no time or time zone, so a holiday never moves a day
/// because of daylight saving or the device's zone. Gregorian calendar.
public struct CalendarDay: Hashable, Comparable, Codable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    /// Creates the date; out-of-range months roll over the year and the day is clamped to the
    /// month's last day (February 31 becomes 28 or 29).
    public init(_ year: Int, _ month: Int, _ day: Int) {
        let index = year * 12 + (month - 1)
        let normalizedYear = Int((Double(index) / 12).rounded(.down))
        let normalizedMonth = index - normalizedYear * 12 + 1
        self.year = normalizedYear
        self.month = normalizedMonth
        self.day = min(max(day, 1), Self.daysInMonth(year: normalizedYear, month: normalizedMonth))
    }

    /// The day of `date` in `calendar` (Gregorian in the current time zone by default).
    public init(_ date: Date, calendar: Calendar = .gregorianCurrentZone) {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(parts.year ?? 2000, parts.month ?? 1, parts.day ?? 1)
    }

    public static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 2:
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    /// Day of the week from 1 (Sunday) to 7 (Saturday), like `Calendar.component(.weekday)`.
    public var weekday: Int {
        ((julianDay + 1) % 7 + 7) % 7 + 1
    }

    public var isWeekend: Bool {
        weekday == 1 || weekday == 7
    }

    public func adding(days: Int) -> CalendarDay {
        CalendarDay(julianDay: julianDay + days)
    }

    public func days(until other: CalendarDay) -> Int {
        other.julianDay - julianDay
    }

    /// Noon of the day in `calendar`, safe from time zone and daylight-saving shifts.
    public func date(calendar: Calendar = .gregorianCurrentZone) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)) ?? Date(timeIntervalSince1970: 0)
    }

    public static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    // MARK: Julian day number

    var julianDay: Int {
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    init(julianDay: Int) {
        let a = julianDay + 32044
        let b = (4 * a + 3) / 146_097
        let c = a - 146_097 * b / 4
        let d = (4 * c + 3) / 1461
        let e = c - 1461 * d / 4
        let m = (5 * e + 2) / 153
        self.init(100 * b + d - 4800 + m / 10, m + 3 - 12 * (m / 10), e - (153 * m + 2) / 5 + 1)
    }
}

public extension Calendar {
    /// Gregorian calendar in the device's current time zone.
    static var gregorianCurrentZone: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }
}

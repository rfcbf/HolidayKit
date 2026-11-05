import Foundation

/// Business days for due dates: a date on a holiday (and, when enabled, on Saturday or Sunday)
/// moves to the next business day, like bank slips and card statements in Brazil. Combines a
/// country's national holidays with the person's own (city, state, a bridge day).
public struct BusinessDayCalendar: Equatable, Sendable {
    public struct RecurringHoliday: Equatable, Hashable, Sendable {
        public let month: Int
        public let day: Int
        public let name: String

        public init(month: Int, day: Int, name: String) {
            self.month = month
            self.day = day
            self.name = name
        }
    }

    /// ISO country code, or `nil` for no national holidays.
    public let countryCode: String?
    public let shiftsHolidays: Bool
    public let shiftsWeekends: Bool
    /// The person's holidays on an exact date.
    public let customHolidays: [CalendarDay: String]
    /// The person's holidays that repeat every year on the same month and day.
    public let recurringHolidays: [RecurringHoliday]

    /// No shifting at all: due dates stay where they were calculated.
    public static let none = BusinessDayCalendar(countryCode: nil, shiftsHolidays: false, shiftsWeekends: false)

    public init(
        countryCode: String?,
        shiftsHolidays: Bool = true,
        shiftsWeekends: Bool = true,
        customHolidays: [CalendarDay: String] = [:],
        recurringHolidays: [RecurringHoliday] = []
    ) {
        self.countryCode = countryCode?.uppercased()
        self.shiftsHolidays = shiftsHolidays
        self.shiftsWeekends = shiftsWeekends
        self.customHolidays = customHolidays
        self.recurringHolidays = recurringHolidays
    }

    public var country: HolidayCountry? {
        countryCode.flatMap(HolidayCatalog.country)
    }

    /// The holiday's name on `date` in `locale`'s language: the person's own first (as typed),
    /// then the national one.
    public func holidayName(on date: CalendarDay, locale: Locale = .current) -> String? {
        if let custom = customHolidays[date] {
            return custom
        }
        if let recurring = recurringHolidays.first(where: { $0.month == date.month && $0.day == date.day }) {
            return recurring.name
        }
        return country?.holidays(in: date.year)[date]?.localizedName(locale)
    }

    /// All holidays of a month, for calendars.
    public func holidays(year: Int, month: Int, locale: Locale = .current) -> [CalendarDay: String] {
        var result: [CalendarDay: String] = [:]
        for number in 1 ... CalendarDay.daysInMonth(year: year, month: month) {
            let date = CalendarDay(year, month, number)
            if let name = holidayName(on: date, locale: locale) {
                result[date] = name
            }
        }
        return result
    }

    public func isBusinessDay(_ date: CalendarDay) -> Bool {
        if shiftsWeekends, date.isWeekend {
            return false
        }
        return !(shiftsHolidays && isHoliday(date))
    }

    public func isHoliday(_ date: CalendarDay) -> Bool {
        customHolidays[date] != nil
            || recurringHolidays.contains { $0.month == date.month && $0.day == date.day }
            || country?.holidays(in: date.year)[date] != nil
    }

    /// `date` itself when it is a business day; otherwise the next one.
    public func nextBusinessDay(onOrAfter date: CalendarDay) -> CalendarDay {
        var current = date
        var steps = 0
        while !isBusinessDay(current), steps < 31 {
            current = current.adding(days: 1)
            steps += 1
        }
        return current
    }
}

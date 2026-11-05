import Foundation

/// National holidays of a country (ISO 3166-1 alpha-2 code, "BR").
public struct HolidayCountry: Identifiable, Equatable, Hashable, Sendable {
    public let code: String
    /// Language of the official names (ISO 639-1).
    public let language: String
    public let holidays: [Holiday]

    public init(code: String, language: String, holidays: [Holiday]) {
        self.code = code.uppercased()
        self.language = language
        self.holidays = holidays.map { holiday in
            var copy = holiday
            copy.officialLanguage = language
            return copy
        }
    }

    public var id: String {
        code
    }

    /// Holidays of the year by date; when two fall on the same day, the first listed wins.
    public func holidays(in year: Int) -> [CalendarDay: Holiday] {
        var result: [CalendarDay: Holiday] = [:]
        for holiday in holidays {
            let date = holiday.rule.date(in: year)
            if result[date] == nil {
                result[date] = holiday
            }
        }
        return result
    }

    /// Holidays of the year by date, named in `locale`'s language.
    public func holidayNames(in year: Int, locale: Locale = .current) -> [CalendarDay: String] {
        holidays(in: year).mapValues { $0.localizedName(locale) }
    }

    /// The country's name in `locale` ("Brasil", "Brazil").
    public func localizedName(_ locale: Locale = .current) -> String {
        locale.localizedString(forRegionCode: code) ?? code
    }

    /// The flag emoji built from the code's regional indicator symbols.
    public var flag: String {
        code.unicodeScalars
            .compactMap { UnicodeScalar(127_397 + $0.value) }
            .map(String.init)
            .joined()
    }
}

/// The countries HolidayKit knows. National holidays only (no state or city ones): apps let people
/// add their local holidays on top, see `BusinessDayCalendar`.
public enum HolidayCatalog {
    public static func country(_ code: String) -> HolidayCountry? {
        countries.first { $0.code == code.uppercased() }
    }

    /// The catalog sorted by the country's name in `locale`.
    public static func sortedCountries(_ locale: Locale = .current) -> [HolidayCountry] {
        countries.sorted { $0.localizedName(locale).localizedStandardCompare($1.localizedName(locale)) == .orderedAscending }
    }

    public static let countries: [HolidayCountry] = [
        brazil, portugal, unitedStates, canada, unitedKingdom, mexico, spain, colombia, france, germany, italy
    ]

    static let brazil = HolidayCountry(code: "BR", language: "pt", holidays: [
        Holiday("new_year", "Confraternização Universal", .fixed(month: 1, day: 1)),
        Holiday("carnival", "Carnaval", .easter(offset: -48)),
        Holiday("carnival", "Carnaval", .easter(offset: -47)),
        Holiday("good_friday", "Sexta-feira Santa", .easter(offset: -2)),
        Holiday("br.tiradentes", "Tiradentes", .fixed(month: 4, day: 21)),
        Holiday("labour_day", "Dia do Trabalho", .fixed(month: 5, day: 1)),
        Holiday("corpus_christi", "Corpus Christi", .easter(offset: 60)),
        Holiday("independence_day", "Independência do Brasil", .fixed(month: 9, day: 7)),
        Holiday("br.aparecida", "Nossa Senhora Aparecida", .fixed(month: 10, day: 12)),
        Holiday("all_souls", "Finados", .fixed(month: 11, day: 2)),
        Holiday("br.republic", "Proclamação da República", .fixed(month: 11, day: 15)),
        Holiday("br.black_consciousness", "Dia da Consciência Negra", .fixed(month: 11, day: 20)),
        Holiday("christmas", "Natal", .fixed(month: 12, day: 25))
    ])

    static let portugal = HolidayCountry(code: "PT", language: "pt", holidays: [
        Holiday("new_year", "Ano Novo", .fixed(month: 1, day: 1)),
        Holiday("good_friday", "Sexta-feira Santa", .easter(offset: -2)),
        Holiday("easter_sunday", "Páscoa", .easter(offset: 0)),
        Holiday("pt.freedom", "Dia da Liberdade", .fixed(month: 4, day: 25)),
        Holiday("labour_day", "Dia do Trabalhador", .fixed(month: 5, day: 1)),
        Holiday("corpus_christi", "Corpo de Deus", .easter(offset: 60)),
        Holiday("pt.portugal_day", "Dia de Portugal", .fixed(month: 6, day: 10)),
        Holiday("assumption", "Assunção de Nossa Senhora", .fixed(month: 8, day: 15)),
        Holiday("republic_day", "Implantação da República", .fixed(month: 10, day: 5)),
        Holiday("all_saints", "Dia de Todos os Santos", .fixed(month: 11, day: 1)),
        Holiday("pt.restoration", "Restauração da Independência", .fixed(month: 12, day: 1)),
        Holiday("immaculate_conception", "Imaculada Conceição", .fixed(month: 12, day: 8)),
        Holiday("christmas", "Natal", .fixed(month: 12, day: 25))
    ])

    static let unitedStates = HolidayCountry(code: "US", language: "en", holidays: [
        Holiday("new_year", "New Year's Day", .fixed(month: 1, day: 1)),
        Holiday("us.mlk", "Martin Luther King Jr. Day", .weekday(month: 1, weekday: 2, ordinal: 3)),
        Holiday("us.presidents", "Presidents' Day", .weekday(month: 2, weekday: 2, ordinal: 3)),
        Holiday("us.memorial", "Memorial Day", .weekday(month: 5, weekday: 2, ordinal: -1)),
        Holiday("us.juneteenth", "Juneteenth", .fixed(month: 6, day: 19)),
        Holiday("independence_day", "Independence Day", .fixed(month: 7, day: 4)),
        Holiday("labour_day", "Labor Day", .weekday(month: 9, weekday: 2, ordinal: 1)),
        Holiday("columbus_day", "Columbus Day", .weekday(month: 10, weekday: 2, ordinal: 2)),
        Holiday("us.veterans", "Veterans Day", .fixed(month: 11, day: 11)),
        Holiday("thanksgiving", "Thanksgiving Day", .weekday(month: 11, weekday: 5, ordinal: 4)),
        Holiday("christmas", "Christmas Day", .fixed(month: 12, day: 25))
    ])

    static let canada = HolidayCountry(code: "CA", language: "en", holidays: [
        Holiday("new_year", "New Year's Day", .fixed(month: 1, day: 1)),
        Holiday("good_friday", "Good Friday", .easter(offset: -2)),
        Holiday("ca.victoria", "Victoria Day", .mondayBefore(month: 5, day: 25)),
        Holiday("ca.canada_day", "Canada Day", .fixed(month: 7, day: 1)),
        Holiday("labour_day", "Labour Day", .weekday(month: 9, weekday: 2, ordinal: 1)),
        Holiday("thanksgiving", "Thanksgiving", .weekday(month: 10, weekday: 2, ordinal: 2)),
        Holiday("ca.remembrance", "Remembrance Day", .fixed(month: 11, day: 11)),
        Holiday("christmas", "Christmas Day", .fixed(month: 12, day: 25)),
        Holiday("boxing_day", "Boxing Day", .fixed(month: 12, day: 26))
    ])

    static let unitedKingdom = HolidayCountry(code: "GB", language: "en", holidays: [
        Holiday("new_year", "New Year's Day", .fixed(month: 1, day: 1)),
        Holiday("good_friday", "Good Friday", .easter(offset: -2)),
        Holiday("easter_monday", "Easter Monday", .easter(offset: 1)),
        Holiday("gb.early_may", "Early May bank holiday", .weekday(month: 5, weekday: 2, ordinal: 1)),
        Holiday("gb.spring", "Spring bank holiday", .weekday(month: 5, weekday: 2, ordinal: -1)),
        Holiday("gb.summer", "Summer bank holiday", .weekday(month: 8, weekday: 2, ordinal: -1)),
        Holiday("christmas", "Christmas Day", .fixed(month: 12, day: 25)),
        Holiday("boxing_day", "Boxing Day", .fixed(month: 12, day: 26))
    ])

    static let mexico = HolidayCountry(code: "MX", language: "es", holidays: [
        Holiday("new_year", "Año Nuevo", .fixed(month: 1, day: 1)),
        Holiday("constitution_day", "Día de la Constitución", .weekday(month: 2, weekday: 2, ordinal: 1)),
        Holiday("mx.juarez", "Natalicio de Benito Juárez", .weekday(month: 3, weekday: 2, ordinal: 3)),
        Holiday("labour_day", "Día del Trabajo", .fixed(month: 5, day: 1)),
        Holiday("independence_day", "Día de la Independencia", .fixed(month: 9, day: 16)),
        Holiday("mx.revolution", "Día de la Revolución", .weekday(month: 11, weekday: 2, ordinal: 3)),
        Holiday("christmas", "Navidad", .fixed(month: 12, day: 25))
    ])

    static let spain = HolidayCountry(code: "ES", language: "es", holidays: [
        Holiday("new_year", "Año Nuevo", .fixed(month: 1, day: 1)),
        Holiday("epiphany", "Epifanía del Señor", .fixed(month: 1, day: 6)),
        Holiday("good_friday", "Viernes Santo", .easter(offset: -2)),
        Holiday("labour_day", "Fiesta del Trabajo", .fixed(month: 5, day: 1)),
        Holiday("assumption", "Asunción de la Virgen", .fixed(month: 8, day: 15)),
        Holiday("es.national_day", "Fiesta Nacional de España", .fixed(month: 10, day: 12)),
        Holiday("all_saints", "Todos los Santos", .fixed(month: 11, day: 1)),
        Holiday("constitution_day", "Día de la Constitución", .fixed(month: 12, day: 6)),
        Holiday("immaculate_conception", "Inmaculada Concepción", .fixed(month: 12, day: 8)),
        Holiday("christmas", "Navidad", .fixed(month: 12, day: 25))
    ])

    static let colombia = HolidayCountry(code: "CO", language: "es", holidays: [
        Holiday("new_year", "Año Nuevo", .fixed(month: 1, day: 1)),
        Holiday("epiphany", "Día de los Reyes Magos", .nextMonday(month: 1, day: 6)),
        Holiday("st_joseph", "Día de San José", .nextMonday(month: 3, day: 19)),
        Holiday("maundy_thursday", "Jueves Santo", .easter(offset: -3)),
        Holiday("good_friday", "Viernes Santo", .easter(offset: -2)),
        Holiday("labour_day", "Día del Trabajo", .fixed(month: 5, day: 1)),
        Holiday("ascension", "Ascensión del Señor", .easter(offset: 43)),
        Holiday("corpus_christi", "Corpus Christi", .easter(offset: 64)),
        Holiday("sacred_heart", "Sagrado Corazón", .easter(offset: 71)),
        Holiday("sts_peter_paul", "San Pedro y San Pablo", .nextMonday(month: 6, day: 29)),
        Holiday("independence_day", "Día de la Independencia", .fixed(month: 7, day: 20)),
        Holiday("co.boyaca", "Batalla de Boyacá", .fixed(month: 8, day: 7)),
        Holiday("assumption", "La Asunción de la Virgen", .nextMonday(month: 8, day: 15)),
        Holiday("columbus_day", "Día de la Raza", .nextMonday(month: 10, day: 12)),
        Holiday("all_saints", "Todos los Santos", .nextMonday(month: 11, day: 1)),
        Holiday("co.cartagena", "Independencia de Cartagena", .nextMonday(month: 11, day: 11)),
        Holiday("immaculate_conception", "Inmaculada Concepción", .fixed(month: 12, day: 8)),
        Holiday("christmas", "Navidad", .fixed(month: 12, day: 25))
    ])

    static let france = HolidayCountry(code: "FR", language: "fr", holidays: [
        Holiday("new_year", "Jour de l'An", .fixed(month: 1, day: 1)),
        Holiday("easter_monday", "Lundi de Pâques", .easter(offset: 1)),
        Holiday("labour_day", "Fête du Travail", .fixed(month: 5, day: 1)),
        Holiday("fr.victory", "Victoire 1945", .fixed(month: 5, day: 8)),
        Holiday("ascension", "Ascension", .easter(offset: 39)),
        Holiday("whit_monday", "Lundi de Pentecôte", .easter(offset: 50)),
        Holiday("fr.bastille", "Fête nationale", .fixed(month: 7, day: 14)),
        Holiday("assumption", "Assomption", .fixed(month: 8, day: 15)),
        Holiday("all_saints", "Toussaint", .fixed(month: 11, day: 1)),
        Holiday("fr.armistice", "Armistice 1918", .fixed(month: 11, day: 11)),
        Holiday("christmas", "Noël", .fixed(month: 12, day: 25))
    ])

    static let germany = HolidayCountry(code: "DE", language: "de", holidays: [
        Holiday("new_year", "Neujahr", .fixed(month: 1, day: 1)),
        Holiday("good_friday", "Karfreitag", .easter(offset: -2)),
        Holiday("easter_monday", "Ostermontag", .easter(offset: 1)),
        Holiday("labour_day", "Tag der Arbeit", .fixed(month: 5, day: 1)),
        Holiday("ascension", "Christi Himmelfahrt", .easter(offset: 39)),
        Holiday("whit_monday", "Pfingstmontag", .easter(offset: 50)),
        Holiday("de.unity", "Tag der Deutschen Einheit", .fixed(month: 10, day: 3)),
        Holiday("christmas", "1. Weihnachtstag", .fixed(month: 12, day: 25)),
        Holiday("boxing_day", "2. Weihnachtstag", .fixed(month: 12, day: 26))
    ])

    static let italy = HolidayCountry(code: "IT", language: "it", holidays: [
        Holiday("new_year", "Capodanno", .fixed(month: 1, day: 1)),
        Holiday("epiphany", "Epifania", .fixed(month: 1, day: 6)),
        Holiday("easter_monday", "Lunedì dell'Angelo", .easter(offset: 1)),
        Holiday("it.liberation", "Festa della Liberazione", .fixed(month: 4, day: 25)),
        Holiday("labour_day", "Festa del Lavoro", .fixed(month: 5, day: 1)),
        Holiday("republic_day", "Festa della Repubblica", .fixed(month: 6, day: 2)),
        Holiday("assumption", "Ferragosto", .fixed(month: 8, day: 15)),
        Holiday("all_saints", "Ognissanti", .fixed(month: 11, day: 1)),
        Holiday("immaculate_conception", "Immacolata Concezione", .fixed(month: 12, day: 8)),
        Holiday("christmas", "Natale", .fixed(month: 12, day: 25)),
        Holiday("boxing_day", "Santo Stefano", .fixed(month: 12, day: 26))
    ])
}

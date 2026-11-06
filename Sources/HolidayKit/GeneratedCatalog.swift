import Foundation

/// Countries from `Resources/holidays.json` (see `Scripts/generate_catalog.py`). Read once, the
/// first time the catalog is used.
enum GeneratedCatalog {
    private struct File: Decodable {
        struct Meta: Decodable {
            let source: String
        }

        struct Country: Decodable {
            let language: String
            let holidays: [Entry]
        }

        struct Entry: Decodable {
            let key: String
            let name: String
            let rule: String
            let en: String?
            let from: Int?
            let until: Int?
        }

        let meta: Meta
        let countries: [String: Country]
    }

    private static let file: File? = {
        guard let url = Bundle.module.url(forResource: "holidays", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(File.self, from: data)
    }()

    static var source: String {
        file?.meta.source ?? ""
    }

    static let countries: [HolidayCountry] = (file?.countries ?? [:]).map { code, country in
        HolidayCountry(code: code, language: country.language, holidays: country.holidays.compactMap { entry in
            guard let rule = HolidayRule(encoded: entry.rule) else { return nil }
            return Holiday(entry.key, entry.name, rule, englishName: entry.en, firstYear: entry.from, lastYear: entry.until)
        })
    }
}

extension HolidayRule {
    /// Parses the compact form of the JSON file: "fixed:12-25", "easter:-2", "orthodox:1",
    /// "weekday:1,2,3" (month, weekday, ordinal) and "dates:20260101,20260220".
    init?(encoded: String) {
        guard let colon = encoded.firstIndex(of: ":") else { return nil }
        let kind = encoded[..<colon]
        let value = encoded[encoded.index(after: colon)...]
        let numbers = { (separator: Character) in value.split(separator: separator).compactMap { Int($0) } }
        switch kind {
        case "fixed":
            let parts = numbers("-")
            guard parts.count == 2 else { return nil }
            self = .fixed(month: parts[0], day: parts[1])
        case "easter":
            guard let offset = Int(value) else { return nil }
            self = .easter(offset: offset)
        case "orthodox":
            guard let offset = Int(value) else { return nil }
            self = .orthodoxEaster(offset: offset)
        case "weekday":
            let parts = numbers(",")
            guard parts.count == 3 else { return nil }
            self = .weekday(month: parts[0], weekday: parts[1], ordinal: parts[2])
        case "dates":
            let days = numbers(",").map { CalendarDay($0 / 10000, $0 / 100 % 100, $0 % 100) }
            guard !days.isEmpty else { return nil }
            self = .dates(days)
        default:
            return nil
        }
    }
}

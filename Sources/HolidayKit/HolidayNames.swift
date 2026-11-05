import Foundation

/// Holiday names in each supported language, by holiday key. Kept in code (no resource bundle) so
/// the package works the same everywhere. Languages: English, Portuguese, Spanish, French, German
/// and Italian. A missing language falls back to English, then to the official name.
enum HolidayNames {
    static let languages = ["en", "pt", "es", "fr", "de", "it"]

    // swiftlint:disable line_length
    static let table: [String: [String: String]] = [
        // Shared
        "new_year": ["en": "New Year's Day", "pt": "Ano-Novo", "es": "Año Nuevo", "fr": "Jour de l'An", "de": "Neujahr", "it": "Capodanno"],
        "epiphany": ["en": "Epiphany", "pt": "Dia de Reis", "es": "Día de Reyes", "fr": "Épiphanie", "de": "Heilige Drei Könige", "it": "Epifania"],
        "carnival": ["en": "Carnival", "pt": "Carnaval", "es": "Carnaval", "fr": "Carnaval", "de": "Karneval", "it": "Carnevale"],
        "st_joseph": ["en": "Saint Joseph's Day", "pt": "Dia de São José", "es": "Día de San José", "fr": "Saint-Joseph", "de": "Josefstag", "it": "San Giuseppe"],
        "maundy_thursday": ["en": "Maundy Thursday", "pt": "Quinta-feira Santa", "es": "Jueves Santo", "fr": "Jeudi saint", "de": "Gründonnerstag", "it": "Giovedì santo"],
        "good_friday": ["en": "Good Friday", "pt": "Sexta-feira Santa", "es": "Viernes Santo", "fr": "Vendredi saint", "de": "Karfreitag", "it": "Venerdì santo"],
        "easter_sunday": ["en": "Easter Sunday", "pt": "Páscoa", "es": "Domingo de Pascua", "fr": "Pâques", "de": "Ostersonntag", "it": "Pasqua"],
        "easter_monday": ["en": "Easter Monday", "pt": "Segunda-feira de Páscoa", "es": "Lunes de Pascua", "fr": "Lundi de Pâques", "de": "Ostermontag", "it": "Lunedì dell'Angelo"],
        "labour_day": ["en": "Labour Day", "pt": "Dia do Trabalho", "es": "Día del Trabajo", "fr": "Fête du Travail", "de": "Tag der Arbeit", "it": "Festa del Lavoro"],
        "ascension": ["en": "Ascension Day", "pt": "Ascensão", "es": "Ascensión del Señor", "fr": "Ascension", "de": "Christi Himmelfahrt", "it": "Ascensione"],
        "whit_monday": ["en": "Whit Monday", "pt": "Segunda-feira de Pentecostes", "es": "Lunes de Pentecostés", "fr": "Lundi de Pentecôte", "de": "Pfingstmontag", "it": "Lunedì di Pentecoste"],
        "corpus_christi": ["en": "Corpus Christi", "pt": "Corpus Christi", "es": "Corpus Christi", "fr": "Fête-Dieu", "de": "Fronleichnam", "it": "Corpus Domini"],
        "sacred_heart": ["en": "Sacred Heart", "pt": "Sagrado Coração", "es": "Sagrado Corazón", "fr": "Sacré-Cœur", "de": "Herz-Jesu-Fest", "it": "Sacro Cuore"],
        "sts_peter_paul": ["en": "Saints Peter and Paul", "pt": "São Pedro e São Paulo", "es": "San Pedro y San Pablo", "fr": "Saints Pierre et Paul", "de": "Peter und Paul", "it": "Santi Pietro e Paolo"],
        "assumption": ["en": "Assumption Day", "pt": "Assunção de Nossa Senhora", "es": "Asunción de la Virgen", "fr": "Assomption", "de": "Mariä Himmelfahrt", "it": "Assunzione di Maria"],
        "all_saints": ["en": "All Saints' Day", "pt": "Dia de Todos os Santos", "es": "Todos los Santos", "fr": "Toussaint", "de": "Allerheiligen", "it": "Ognissanti"],
        "all_souls": ["en": "All Souls' Day", "pt": "Finados", "es": "Día de los Difuntos", "fr": "Jour des Morts", "de": "Allerseelen", "it": "Commemorazione dei defunti"],
        "immaculate_conception": ["en": "Immaculate Conception", "pt": "Imaculada Conceição", "es": "Inmaculada Concepción", "fr": "Immaculée Conception", "de": "Mariä Empfängnis", "it": "Immacolata Concezione"],
        "christmas": ["en": "Christmas Day", "pt": "Natal", "es": "Navidad", "fr": "Noël", "de": "Erster Weihnachtstag", "it": "Natale"],
        "boxing_day": ["en": "Boxing Day", "pt": "Dia de Santo Estêvão", "es": "San Esteban", "fr": "Saint-Étienne", "de": "Zweiter Weihnachtstag", "it": "Santo Stefano"],
        "independence_day": ["en": "Independence Day", "pt": "Dia da Independência", "es": "Día de la Independencia", "fr": "Fête de l'Indépendance", "de": "Unabhängigkeitstag", "it": "Giorno dell'Indipendenza"],
        "constitution_day": ["en": "Constitution Day", "pt": "Dia da Constituição", "es": "Día de la Constitución", "fr": "Jour de la Constitution", "de": "Tag der Verfassung", "it": "Giorno della Costituzione"],
        "thanksgiving": ["en": "Thanksgiving", "pt": "Dia de Ação de Graças", "es": "Día de Acción de Gracias", "fr": "Action de grâce", "de": "Erntedankfest", "it": "Giorno del Ringraziamento"],
        "columbus_day": ["en": "Columbus Day", "pt": "Dia de Colombo", "es": "Día de la Raza", "fr": "Jour de Christophe Colomb", "de": "Columbus Day", "it": "Giorno di Colombo"],
        "republic_day": ["en": "Republic Day", "pt": "Dia da República", "es": "Día de la República", "fr": "Fête de la République", "de": "Tag der Republik", "it": "Festa della Repubblica"],
        // Brazil
        "br.tiradentes": ["en": "Tiradentes Day", "pt": "Tiradentes", "es": "Día de Tiradentes", "fr": "Jour de Tiradentes", "de": "Tiradentes-Tag", "it": "Giorno di Tiradentes"],
        "br.aparecida": ["en": "Our Lady of Aparecida", "pt": "Nossa Senhora Aparecida", "es": "Nuestra Señora Aparecida", "fr": "Notre-Dame d'Aparecida", "de": "Unsere Liebe Frau von Aparecida", "it": "Nostra Signora di Aparecida"],
        "br.republic": ["en": "Proclamation of the Republic", "pt": "Proclamação da República", "es": "Proclamación de la República", "fr": "Proclamation de la République", "de": "Ausrufung der Republik", "it": "Proclamazione della Repubblica"],
        "br.black_consciousness": ["en": "Black Consciousness Day", "pt": "Dia da Consciência Negra", "es": "Día de la Conciencia Negra", "fr": "Journée de la conscience noire", "de": "Tag des Schwarzen Bewusstseins", "it": "Giornata della coscienza nera"],
        // Portugal
        "pt.freedom": ["en": "Freedom Day", "pt": "Dia da Liberdade", "es": "Día de la Libertad", "fr": "Jour de la Liberté", "de": "Tag der Freiheit", "it": "Festa della Libertà"],
        "pt.portugal_day": ["en": "Portugal Day", "pt": "Dia de Portugal", "es": "Día de Portugal", "fr": "Jour du Portugal", "de": "Tag Portugals", "it": "Giornata del Portogallo"],
        "pt.restoration": ["en": "Restoration of Independence", "pt": "Restauração da Independência", "es": "Restauración de la Independencia", "fr": "Restauration de l'indépendance", "de": "Wiederherstellung der Unabhängigkeit", "it": "Restaurazione dell'indipendenza"],
        // United States
        "us.mlk": ["en": "Martin Luther King Jr. Day", "pt": "Dia de Martin Luther King Jr.", "es": "Día de Martin Luther King Jr.", "fr": "Jour de Martin Luther King", "de": "Martin-Luther-King-Tag", "it": "Giorno di Martin Luther King"],
        "us.presidents": ["en": "Presidents' Day", "pt": "Dia dos Presidentes", "es": "Día de los Presidentes", "fr": "Jour des présidents", "de": "Presidents' Day", "it": "Giorno dei Presidenti"],
        "us.memorial": ["en": "Memorial Day", "pt": "Dia da Memória", "es": "Día de los Caídos", "fr": "Memorial Day", "de": "Memorial Day", "it": "Memorial Day"],
        "us.juneteenth": ["en": "Juneteenth", "pt": "Juneteenth", "es": "Juneteenth", "fr": "Juneteenth", "de": "Juneteenth", "it": "Juneteenth"],
        "us.veterans": ["en": "Veterans Day", "pt": "Dia dos Veteranos", "es": "Día de los Veteranos", "fr": "Jour des anciens combattants", "de": "Veterans Day", "it": "Giorno dei Veterani"],
        // Canada
        "ca.victoria": ["en": "Victoria Day", "pt": "Dia da Rainha Vitória", "es": "Día de la Reina Victoria", "fr": "Fête de la Reine", "de": "Victoria Day", "it": "Victoria Day"],
        "ca.canada_day": ["en": "Canada Day", "pt": "Dia do Canadá", "es": "Día de Canadá", "fr": "Fête du Canada", "de": "Kanadatag", "it": "Festa del Canada"],
        "ca.remembrance": ["en": "Remembrance Day", "pt": "Dia da Lembrança", "es": "Día del Recuerdo", "fr": "Jour du Souvenir", "de": "Gedenktag", "it": "Giorno della Memoria"],
        // United Kingdom
        "gb.early_may": ["en": "Early May bank holiday", "pt": "Feriado bancário do início de maio", "es": "Festivo bancario de principios de mayo", "fr": "Jour férié de début mai", "de": "Bankfeiertag Anfang Mai", "it": "Festa bancaria di inizio maggio"],
        "gb.spring": ["en": "Spring bank holiday", "pt": "Feriado bancário da primavera", "es": "Festivo bancario de primavera", "fr": "Jour férié de printemps", "de": "Frühlings-Bankfeiertag", "it": "Festa bancaria di primavera"],
        "gb.summer": ["en": "Summer bank holiday", "pt": "Feriado bancário de verão", "es": "Festivo bancario de verano", "fr": "Jour férié d'été", "de": "Sommer-Bankfeiertag", "it": "Festa bancaria d'estate"],
        // Mexico
        "mx.juarez": ["en": "Benito Juárez's Birthday", "pt": "Natalício de Benito Juárez", "es": "Natalicio de Benito Juárez", "fr": "Anniversaire de Benito Juárez", "de": "Geburtstag von Benito Juárez", "it": "Natalizio di Benito Juárez"],
        "mx.revolution": ["en": "Revolution Day", "pt": "Dia da Revolução", "es": "Día de la Revolución", "fr": "Jour de la Révolution", "de": "Tag der Revolution", "it": "Giorno della Rivoluzione"],
        // Spain
        "es.national_day": ["en": "National Day of Spain", "pt": "Festa Nacional da Espanha", "es": "Fiesta Nacional de España", "fr": "Fête nationale espagnole", "de": "Spanischer Nationalfeiertag", "it": "Festa nazionale spagnola"],
        // Colombia
        "co.boyaca": ["en": "Battle of Boyacá", "pt": "Batalha de Boyacá", "es": "Batalla de Boyacá", "fr": "Bataille de Boyacá", "de": "Schlacht von Boyacá", "it": "Battaglia di Boyacá"],
        "co.cartagena": ["en": "Independence of Cartagena", "pt": "Independência de Cartagena", "es": "Independencia de Cartagena", "fr": "Indépendance de Carthagène", "de": "Unabhängigkeit Cartagenas", "it": "Indipendenza di Cartagena"],
        // France
        "fr.victory": ["en": "Victory in Europe Day", "pt": "Dia da Vitória", "es": "Día de la Victoria", "fr": "Victoire 1945", "de": "Tag der Befreiung", "it": "Giorno della Vittoria"],
        "fr.bastille": ["en": "Bastille Day", "pt": "Festa Nacional da França", "es": "Fiesta Nacional de Francia", "fr": "Fête nationale", "de": "Französischer Nationalfeiertag", "it": "Festa nazionale francese"],
        "fr.armistice": ["en": "Armistice Day", "pt": "Dia do Armistício", "es": "Día del Armisticio", "fr": "Armistice 1918", "de": "Waffenstillstandstag", "it": "Giorno dell'Armistizio"],
        // Germany
        "de.unity": ["en": "German Unity Day", "pt": "Dia da Unidade Alemã", "es": "Día de la Unidad Alemana", "fr": "Jour de l'Unité allemande", "de": "Tag der Deutschen Einheit", "it": "Giorno dell'Unità tedesca"],
        // Italy
        "it.liberation": ["en": "Liberation Day", "pt": "Dia da Libertação", "es": "Día de la Liberación", "fr": "Fête de la Libération", "de": "Tag der Befreiung", "it": "Festa della Liberazione"]
    ]
    // swiftlint:enable line_length

    /// The name of `key` in `language` ("pt", "en"...), falling back to English.
    static func name(_ key: String, language: String) -> String? {
        guard let names = table[key] else { return nil }
        return names[language] ?? names["en"]
    }
}

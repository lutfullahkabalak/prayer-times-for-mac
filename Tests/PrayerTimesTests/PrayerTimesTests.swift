import Foundation
import Testing
@testable import PrayerTimes

@Test func decodePrayerTimesPayload() throws {
    let json = """
    {
      "imsak": "04:10",
      "gunes": "05:54",
      "ogle": "13:15",
      "ikindi": "17:09",
      "aksam": "20:27",
      "yatsi": "22:04"
    }
    """.data(using: .utf8)!

    let payload = try JSONDecoder().decode(PrayerTimesPayload.self, from: json)
    #expect(payload.imsak == "04:10")
    #expect(payload.time(for: .ikindi) == "17:09")
}

@Test func decodeAPIResponseCountries() throws {
    let json = """
    {
      "success": true,
      "code": 200,
      "message": "ok",
      "data": [
        { "_id": "2", "name": "TÜRKİYE", "name_en": "TÜRKİYE" }
      ]
    }
    """.data(using: .utf8)!

    let response = try JSONDecoder().decode(APIResponse<[Country]>.self, from: json)
    #expect(response.data.count == 1)
    #expect(response.data[0].id == "2")
}

@Test func decodeDayTimesFromAPI() throws {
    let json = """
    {
      "date": "2026-08-02T00:00:00.000Z",
      "times": {
        "imsak": "04:10",
        "gunes": "05:54",
        "ogle": "13:15",
        "ikindi": "17:09",
        "aksam": "20:27",
        "yatsi": "22:04"
      },
      "hijri_date": {
        "day": 19,
        "month": 2,
        "month_name": "Safer",
        "month_name_en": "Safar",
        "year": 1448,
        "full_date": "19 Safer 1448"
      }
    }
    """.data(using: .utf8)!

    let day = try JSONDecoder().decode(DayTimes.self, from: json)
    #expect(day.times.ogle == "13:15")
    #expect(day.hijriDate?.fullDate == "19 Safer 1448")
}

@Test func activePrayerDuringIkindi() throws {
    let timeZone = TimeZone(identifier: "Europe/Istanbul")!
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone

    var components = DateComponents()
    components.year = 2026
    components.month = 8
    components.day = 2
    components.hour = 18
    components.minute = 0
    let now = try #require(calendar.date(from: components))

    let day = DayTimes(
        date: now,
        times: PrayerTimesPayload(
            imsak: "04:10",
            gunes: "05:54",
            ogle: "13:15",
            ikindi: "17:09",
            aksam: "20:27",
            yatsi: "22:04"
        ),
        hijriDate: nil
    )

    let state = PrayerTimeCalculator.activePrayer(now: now, days: [day], timeZone: timeZone)
    #expect(state?.prayer == .ikindi)
    #expect(state?.remaining ?? 0 > 0)
}

@Test func activePrayerAtMidnightIsYatsi() throws {
    let timeZone = TimeZone(identifier: "Europe/Istanbul")!
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone

    var day2Components = DateComponents()
    day2Components.year = 2026
    day2Components.month = 8
    day2Components.day = 2
    let day2 = try #require(calendar.date(from: day2Components))

    var day1Components = day2Components
    day1Components.day = 1
    let day1 = try #require(calendar.date(from: day1Components))

    let times = PrayerTimesPayload(
        imsak: "04:10",
        gunes: "05:54",
        ogle: "13:15",
        ikindi: "17:09",
        aksam: "20:27",
        yatsi: "22:04"
    )

    let days = [
        DayTimes(date: day1, times: times, hijriDate: nil),
        DayTimes(date: day2, times: times, hijriDate: nil)
    ]

    var midnightComponents = DateComponents()
    midnightComponents.year = 2026
    midnightComponents.month = 8
    midnightComponents.day = 2
    midnightComponents.hour = 0
    midnightComponents.minute = 30
    let now = try #require(calendar.date(from: midnightComponents))

    let state = PrayerTimeCalculator.activePrayer(now: now, days: days, timeZone: timeZone)
    #expect(state?.prayer == .yatsi)
}

@Test func countdownFormatting() {
    #expect(TimeInterval(83).countdownText == "1:23")
    #expect(TimeInterval(4500).menuBarCountdownText == "1:15")
}

@Test func decodeSavedLocationFromDefaultsPayload() throws {
    let json = """
    {"country":{"_id":"2","name":"TÜRKİYE","name_en":"TÜRKİYE"},"province":{"_id":"539","name":"İSTANBUL","name_en":"İSTANBUL","country_id":"2"},"district":{"_id":"9541","name":"İSTANBUL","name_en":"ISTANBUL","state_id":"539","country_id":"2"},"displayName":"İstanbul","timeZoneIdentifier":"Europe/Istanbul"}
    """.data(using: .utf8)!
    let location = try JSONDecoder().decode(SavedLocation.self, from: json)
    #expect(location.district.id == "9541")
}

@Test func decodeMonthlyFromLiveAPI() async throws {
    let api = DiyanetAPI()
    let days = try await api.fetchMonthlyPrayerTimes(districtId: "9541")
    #expect(!days.isEmpty)
    #expect(days[0].times.imsak.count == 5)
}

@Test func isCardActiveRules() {
    #expect(PrayerTimeCalculator.isCardActive(prayer: .gunes, activePrayer: .imsak) == false)
    #expect(PrayerTimeCalculator.isCardActive(prayer: .imsak, activePrayer: .imsak) == true)
    #expect(PrayerTimeCalculator.isCardActive(prayer: .ikindi, activePrayer: .ikindi) == true)
}

@Test func countryAliasMapsTurkeyViaISOAndEnglishName() {
    let countries = [
        Country(id: "2", name: "TÜRKİYE", nameEn: "TÜRKİYE"),
        Country(id: "33", name: "ABD", nameEn: "ABD"),
        Country(id: "15", name: "INGILTERE", nameEn: "INGILTERE"),
        Country(id: "64", name: "S. ARABISTAN", nameEn: "S. ARABISTAN"),
    ]

    #expect(CountryNameMapper.diyanetName(forISOCode: "TR") == "TÜRKİYE")
    #expect(CountryNameMapper.aliasedDiyanetName(for: "Turkey") == "TÜRKİYE")
    #expect(CountryNameMapper.matchCountry(isoCode: "TR", countryName: "Turkey", in: countries)?.id == "2")
    #expect(CountryNameMapper.matchCountry(isoCode: nil, countryName: "Turkey", in: countries)?.id == "2")
    #expect(CountryNameMapper.matchCountry(isoCode: "US", countryName: "United States", in: countries)?.name == "ABD")
    #expect(CountryNameMapper.matchCountry(isoCode: "GB", countryName: "United Kingdom", in: countries)?.name == "INGILTERE")
    #expect(CountryNameMapper.matchCountry(isoCode: nil, countryName: "Saudi Arabia", in: countries)?.name == "S. ARABISTAN")
}

@Test func countryAliasCoversCommonEnglishMismatches() {
    let samples: [(String, String)] = [
        ("Germany", "ALMANYA"),
        ("Netherlands", "HOLLANDA"),
        ("Egypt", "MISIR"),
        ("Morocco", "FAS"),
        ("Greece", "YUNANISTAN"),
        ("United Arab Emirates", "BIRLESIK ARAP EMIRLIGI"),
        ("Czechia", "CEK CUMHURIYETI"),
        ("South Korea", "GUNEY KORE"),
    ]
    for (english, diyanet) in samples {
        #expect(CountryNameMapper.aliasedDiyanetName(for: english) == diyanet)
    }
}

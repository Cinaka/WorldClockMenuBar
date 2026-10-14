
import Foundation
import SwiftUI

struct ClockCity: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    let timeZoneID: String

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? .gmt
    }

    static let defaults: [ClockCity] = [
        .init(id: "los-angeles", name: "Los Angeles", timeZoneID: "America/Los_Angeles"),
        .init(id: "new-york", name: "New York", timeZoneID: "America/New_York"),
        .init(id: "london", name: "London", timeZoneID: "Europe/London"),
        .init(id: "beijing", name: "Beijing", timeZoneID: "Asia/Shanghai"),
        .init(id: "tokyo", name: "Tokyo", timeZoneID: "Asia/Tokyo"),
        .init(id: "sydney", name: "Sydney", timeZoneID: "Australia/Sydney"),
        .init(id: "utc", name: "UTC", timeZoneID: "UTC")
    ]
}

@MainActor
final class ClockStore: ObservableObject {
    @Published var cities: [ClockCity] = ClockCity.defaults
    @Published var selectedCityID: String = "beijing"
    @Published var use24Hour = true
    @Published var showCityName = true
    @Published var showClockIcon = true
    @Published var menuBarIconName = "clock"

    // 新增：菜单栏日期、星期、秒数显示选项
    @Published var showDateInMenuBar = false
    @Published var showWeekdayInMenuBar = false
    @Published var showSecondsInMenuBar = false

    static let availableIcons = [
        "clock",
        "clock.fill",
        "globe",
        "globe.americas",
        "globe.europe.africa",
        "globe.asia.australia",
        "sun.max",
        "moon",
        "timer",
        "alarm"
    ]

    private let defaults = UserDefaults.standard
    private var timer: Timer?

    init() {
        load()

        DiagnosticLog.write(
            "ClockStore initialized. City count: \(cities.count), selected: \(selectedCityID)"
        )

        // 每秒触发更新，保证开启秒数后菜单栏实时刷新
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.objectWillChange.send()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }

    var selectedCity: ClockCity {
        cities.first(where: { $0.id == selectedCityID })
            ?? cities.first
            ?? ClockCity.defaults[0]
    }

    // 生成菜单栏显示文本
    // 示例：New York Tue Oct 13 09:05:35
    var menuBarTitle: String {
        var components: [String] = []

        if showCityName {
            components.append(selectedCity.name)
        }

        let now = Date()

        // 星期，例如 Tue
        if showWeekdayInMenuBar {
            components.append(
                formattedDate(
                    now,
                    for: selectedCity,
                    format: "EEE"
                )
            )
        }

        // 日期，例如 Oct 13
        if showDateInMenuBar {
            components.append(
                formattedDate(
                    now,
                    for: selectedCity,
                    format: "MMM d"
                )
            )
        }

        // 时间始终显示；秒数由设置决定
        components.append(timeString(for: selectedCity))

        return components.joined(separator: " ")
    }

    func timeString(for city: ClockCity) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = city.timeZone

        if use24Hour {
            formatter.dateFormat = showSecondsInMenuBar
                ? "HH:mm:ss"
                : "HH:mm"
        } else {
            formatter.dateFormat = showSecondsInMenuBar
                ? "h:mm:ss a"
                : "h:mm a"
        }

        return formatter.string(from: Date())
    }

    private func formattedDate(
        _ date: Date,
        for city: ClockCity,
        format: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = city.timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func dateAndOffset(for city: ClockCity) -> String {
        let now = Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = city.timeZone
        formatter.dateFormat = "EEE, MMM d, yyyy"

        let date = formatter.string(from: now)
        let offset = city.timeZone.secondsFromGMT(for: now)
        let sign = offset >= 0 ? "+" : "−"
        let absOffset = abs(offset)
        let hours = absOffset / 3600
        let minutes = (absOffset % 3600) / 60

        let offsetText = minutes == 0
            ? String(format: "UTC%@%02d:00", sign, hours)
            : String(format: "UTC%@%02d:%02d", sign, hours, minutes)

        return "\(date) · \(offsetText)"
    }

    func select(_ city: ClockCity) {
        guard cities.contains(where: { $0.id == city.id }) else {
            DiagnosticLog.write(
                "Clock selection rejected because the city is not in the list: \(city.id)"
            )
            return
        }

        selectedCityID = city.id
        save()
    }

    func addCity(timeZoneID: String, name: String) {
        guard TimeZone(identifier: timeZoneID) != nil else {
            DiagnosticLog.write(
                "Failed to add clock: invalid time zone \(timeZoneID)"
            )
            return
        }

        guard !cities.contains(where: {
            $0.timeZoneID == timeZoneID
        }) else {
            DiagnosticLog.write(
                "Failed to add clock: duplicate time zone \(timeZoneID)"
            )
            return
        }

        let safeID = timeZoneID
            .lowercased()
            .replacingOccurrences(of: "/", with: "-")

        let displayName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        cities.append(
            ClockCity(
                id: safeID,
                name: displayName.isEmpty ? timeZoneID : displayName,
                timeZoneID: timeZoneID
            )
        )

        DiagnosticLog.write(
            "Clock added: \(displayName.isEmpty ? timeZoneID : displayName) [\(timeZoneID)]"
        )

        save()
    }

    func renameCity(id: String, name: String) {
        guard let index = cities.firstIndex(where: {
            $0.id == id
        }) else {
            DiagnosticLog.write("Rename failed: city ID not found: \(id)")
            return
        }

        let newName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !newName.isEmpty else {
            DiagnosticLog.write("Rename failed: empty display name.")
            return
        }

        cities[index].name = newName

        DiagnosticLog.write("Clock renamed: \(id) -> \(newName)")
        save()
    }

    func remove(at offsets: IndexSet) {
        let removedIDs = offsets.map { cities[$0].id }
        let removedNames = offsets.map { cities[$0].name }

        cities.remove(atOffsets: offsets)

        if cities.isEmpty {
            cities = ClockCity.defaults
            DiagnosticLog.write(
                "Last clock removed; restored default clock list."
            )
        }

        if removedIDs.contains(selectedCityID) {
            selectedCityID = cities.first?.id
                ?? ClockCity.defaults[0].id
        }

        DiagnosticLog.write(
            "Clocks removed: \(removedNames.joined(separator: ", ")). Remaining: \(cities.count)"
        )

        save()
    }

    func removeCity(id: String) {
        guard let index = cities.firstIndex(where: {
            $0.id == id
        }) else {
            DiagnosticLog.write("Remove failed: city ID not found: \(id)")
            return
        }

        remove(at: IndexSet(integer: index))
    }

    func move(from source: IndexSet, to destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
        DiagnosticLog.write("Clock order changed.")
        save()
    }

    private func load() {
        if let data = defaults.data(forKey: "cities"),
           let decoded = try? JSONDecoder().decode(
                [ClockCity].self,
                from: data
           ),
           !decoded.isEmpty {
            cities = decoded
            DiagnosticLog.write(
                "Loaded \(decoded.count) saved clocks."
            )
        } else {
            DiagnosticLog.write(
                "No saved clock list found; using defaults."
            )
        }

        if let id = defaults.string(forKey: "selectedCityID"),
           cities.contains(where: { $0.id == id }) {
            selectedCityID = id
        } else if !cities.contains(where: { $0.id == selectedCityID }) {
            selectedCityID = cities.first?.id
                ?? ClockCity.defaults[0].id
        }

        if !defaults.bool(forKey: "didMigrateTo24HourDefault") {
            use24Hour = true
            defaults.set(true, forKey: "use24Hour")
            defaults.set(true, forKey: "didMigrateTo24HourDefault")

            DiagnosticLog.write(
                "Migrated default time format to 24-hour."
            )
        } else {
            use24Hour = defaults.object(
                forKey: "use24Hour"
            ) as? Bool ?? true
        }

        showCityName = defaults.object(
            forKey: "showCityName"
        ) as? Bool ?? true

        showClockIcon = defaults.object(
            forKey: "showClockIcon"
        ) as? Bool ?? true

        // 新选项默认关闭，升级后保持原有菜单栏外观
        showDateInMenuBar = defaults.object(
            forKey: "showDateInMenuBar"
        ) as? Bool ?? false

        showWeekdayInMenuBar = defaults.object(
            forKey: "showWeekdayInMenuBar"
        ) as? Bool ?? false

        showSecondsInMenuBar = defaults.object(
            forKey: "showSecondsInMenuBar"
        ) as? Bool ?? false

        let savedIcon = defaults.string(
            forKey: "menuBarIconName"
        ) ?? "clock"

        menuBarIconName = Self.availableIcons.contains(savedIcon)
            ? savedIcon
            : "clock"

        DiagnosticLog.write(
            """
            Settings loaded. \
            24-hour: \(use24Hour), \
            city name: \(showCityName), \
            icon: \(showClockIcon), \
            icon name: \(menuBarIconName), \
            date: \(showDateInMenuBar), \
            weekday: \(showWeekdayInMenuBar), \
            seconds: \(showSecondsInMenuBar)
            """
        )
    }

    func save() {
        if let data = try? JSONEncoder().encode(cities) {
            defaults.set(data, forKey: "cities")
        }

        defaults.set(selectedCityID, forKey: "selectedCityID")
        defaults.set(use24Hour, forKey: "use24Hour")
        defaults.set(showCityName, forKey: "showCityName")
        defaults.set(showClockIcon, forKey: "showClockIcon")
        defaults.set(menuBarIconName, forKey: "menuBarIconName")

        // 保存新增的三个选项
        defaults.set(showDateInMenuBar, forKey: "showDateInMenuBar")
        defaults.set(showWeekdayInMenuBar, forKey: "showWeekdayInMenuBar")
        defaults.set(showSecondsInMenuBar, forKey: "showSecondsInMenuBar")

        defaults.set(true, forKey: "didMigrateTo24HourDefault")
    }
}

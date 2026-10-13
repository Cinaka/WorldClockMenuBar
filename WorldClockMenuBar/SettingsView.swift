
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ClockStore

    @State private var cityName = ""
    @State private var timeZoneID = "Europe/Paris"
    @State private var showingAddError = false
    @State private var showingCopySuccess = false
    @State private var showingCopyError = false

    private let suggestedZones = [
        "America/Los_Angeles",
        "America/New_York",
        "America/Chicago",
        "America/Denver",
        "America/Toronto",
        "Europe/London",
        "Europe/Paris",
        "Europe/Berlin",
        "Asia/Shanghai",
        "Asia/Tokyo",
        "Asia/Singapore",
        "Australia/Sydney",
        "Pacific/Auckland",
        "UTC"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("World Clock Settings")
                .font(.title2.bold())

            GroupBox("Display") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker(
                        "Time format",
                        selection: Binding(
                            get: { store.use24Hour ? "24" : "12" },
                            set: {
                                store.use24Hour = ($0 == "24")
                                store.save()
                                DiagnosticLog.write(
                                    "Time format changed to \($0)-hour."
                                )
                            }
                        )
                    ) {
                        Text("24-hour (17:30)").tag("24")
                        Text("12-hour (5:30 PM)").tag("12")
                    }
                    .pickerStyle(.segmented)

                    Toggle(
                        "Show city name in menu bar",
                        isOn: $store.showCityName
                    )
                    .onChange(of: store.showCityName) { value in
                        store.save()
                        DiagnosticLog.write(
                            "Show city name changed to \(value)."
                        )
                    }

                    Toggle(
                        "Show clock icon in menu bar",
                        isOn: $store.showClockIcon
                    )
                    .onChange(of: store.showClockIcon) { value in
                        store.save()
                        DiagnosticLog.write(
                            "Show clock icon changed to \(value)."
                        )
                    }

                    HStack {
                        Text("Menu bar icon")
                        Spacer()

                        Picker(
                            "Menu bar icon",
                            selection: $store.menuBarIconName
                        ) {
                            ForEach(
                                ClockStore.availableIcons,
                                id: \.self
                            ) { iconName in
                                Label(
                                    iconName,
                                    systemImage: iconName
                                )
                                .tag(iconName)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 210)
                        .disabled(!store.showClockIcon)
                        .onChange(of: store.menuBarIconName) { value in
                            store.save()
                            DiagnosticLog.write(
                                "Menu bar icon changed to \(value)."
                            )
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Your clocks") {
                VStack(spacing: 0) {
                    List {
                        ForEach(store.cities) { city in
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(city.name)
                                        .fontWeight(
                                            city.id == store.selectedCityID
                                                ? .semibold
                                                : .regular
                                        )

                                    Text(city.timeZoneID)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if city.id == store.selectedCityID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }

                                Button {
                                    DiagnosticLog.write(
                                        "Removing clock: \(city.name) [\(city.timeZoneID)]"
                                    )
                                    store.removeCity(id: city.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .help("Remove this clock")
                            }
                            .padding(.vertical, 3)
                        }
                        .onMove(perform: store.move)
                    }
                    .frame(minHeight: 130, maxHeight: 190)

                    HStack {
                        Text("Drag clocks to reorder them.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding(.top, 6)
                }
            }

            GroupBox("Add a time zone") {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Time zone", selection: $timeZoneID) {
                        ForEach(suggestedZones, id: \.self) { zone in
                            Text(zone).tag(zone)
                        }
                    }

                    TextField(
                        "Display name (optional)",
                        text: $cityName
                    )
                    .textFieldStyle(.roundedBorder)

                    HStack {
                        Spacer()

                        Button("Add Clock") {
                            if store.cities.contains(where: {
                                $0.timeZoneID == timeZoneID
                            }) {
                                DiagnosticLog.write(
                                    "Attempted to add duplicate time zone: \(timeZoneID)"
                                )
                                showingAddError = true
                            } else {
                                store.addCity(
                                    timeZoneID: timeZoneID,
                                    name: cityName
                                )
                                cityName = ""
                            }
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(.vertical, 4)
            }

            GroupBox("Diagnostics & Logs") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("If something does not work, open or copy the diagnostic log and send it for troubleshooting.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button {
                            DiagnosticLog.openLog()
                        } label: {
                            Label(
                                "Open Log File",
                                systemImage: "doc.text.magnifyingglass"
                            )
                        }

                        Spacer()

                        Button {
                            if DiagnosticLog.copyLog() {
                                showingCopySuccess = true
                            } else {
                                showingCopyError = true
                            }
                        } label: {
                            Label(
                                "Copy Log",
                                systemImage: "doc.on.doc"
                            )
                        }
                    }

                    Text(DiagnosticLog.logPath())
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(18)
        .frame(width: 480, height: 690)
        .alert(
            "This time zone is already in your list.",
            isPresented: $showingAddError
        ) {
            Button("OK", role: .cancel) { }
        }
        .alert(
            "Diagnostic log copied to clipboard.",
            isPresented: $showingCopySuccess
        ) {
            Button("OK", role: .cancel) { }
        }
        .alert(
            "Could not read the diagnostic log. Try opening the log file first.",
            isPresented: $showingCopyError
        ) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            DiagnosticLog.write("Settings window appeared.")
        }
    }
}


import SwiftUI
import AppKit

struct ClockMenuView: View {
    @EnvironmentObject private var store: ClockStore
    @Environment(\.openWindow) private var openWindow

    private var clockListHeight: CGFloat {
        min(max(CGFloat(store.cities.count) * 58, 58), 350)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Text(
                    store.selectedCity.name + "  "
                    + store.timeString(for: store.selectedCity)
                )
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .monospacedDigit()

                Text(store.dateAndOffset(for: store.selectedCity))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .padding(.horizontal, 10)

            ScrollView {
                VStack(spacing: 3) {
                    ForEach(store.cities) { city in
                        Button {
                            DiagnosticLog.write(
                                "Clock selected: \(city.name) [\(city.timeZoneID)]"
                            )
                            store.select(city)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                    .font(.system(size: 18))
                                    .frame(width: 25)

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(city.name)
                                            .fontWeight(
                                                city.id == store.selectedCityID
                                                    ? .semibold
                                                    : .regular
                                            )

                                        Spacer(minLength: 8)

                                        Text(store.timeString(for: city))
                                            .monospacedDigit()
                                    }

                                    Text(store.dateAndOffset(for: city))
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }

                                if city.id == store.selectedCityID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                        .background(
                            city.id == store.selectedCityID
                                ? Color.accentColor.opacity(0.13)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .frame(height: clockListHeight)
            .onAppear {
                DiagnosticLog.write(
                    "Clock menu content appeared. City count: \(store.cities.count)"
                )
            }

            Divider()
                .padding(.horizontal, 10)

            HStack {
                Button {
                    DiagnosticLog.write("Settings button clicked.")
                    openWindow(id: "settings")

                    // 激活应用，尝试将设置窗口带到前台
                    NSApp.activate(ignoringOtherApps: true)
                    
                    DiagnosticLog.write("Requested opening settings window.")
                } label: {
                    Label("Settings…", systemImage: "gearshape")
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    DiagnosticLog.write("Quit button clicked.")
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("q")
            }
            .font(.system(size: 12))
            .padding(12)
        }
        .frame(width: 370)
    }
}

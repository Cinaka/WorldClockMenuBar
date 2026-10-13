
import SwiftUI
import AppKit

@main
struct WorldClockMenuBarApp: App {
    @StateObject private var store = ClockStore()

    init() {
        DiagnosticLog.write("Application launched.")
        DiagnosticLog.write("macOS version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    }

    var body: some Scene {
        MenuBarExtra {
            ClockMenuView()
                .environmentObject(store)
        } label: {
            HStack(spacing: 5) {
                if store.showClockIcon {
                    Image(systemName: store.menuBarIconName)
                }

                Text(store.menuBarTitle)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)

        Window("World Clock Settings", id: "settings") {
            SettingsView()
                .environmentObject(store)
                .frame(
                    minWidth: 480,
                    idealWidth: 480,
                    minHeight: 650,
                    idealHeight: 690
                )
        }
        .defaultSize(width: 480, height: 690)
    }
}

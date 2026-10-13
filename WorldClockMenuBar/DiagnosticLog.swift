import Foundation
import AppKit

enum DiagnosticLog {
    private static let directoryURL: URL = {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return base.appendingPathComponent(
            "WorldClockMenuBar",
            isDirectory: true
        )
    }()

    static var fileURL: URL {
        directoryURL.appendingPathComponent("diagnostics.log")
    }

    static func write(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)\n"

        guard let data = line.data(using: .utf8) else {
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            if FileManager.default.fileExists(atPath: fileURL.path) {
                let handle = try FileHandle(forWritingTo: fileURL)
                defer { try? handle.close() }
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
            } else {
                try data.write(to: fileURL, options: .atomic)
            }
        } catch {
            NSLog(
                "[WorldClockMenuBar] Log write failed: %@",
                error.localizedDescription
            )
        }
    }

    static func openLog() {
        write("User requested opening diagnostic log.")

        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            if !FileManager.default.fileExists(atPath: fileURL.path) {
                try Data().write(to: fileURL)
            }

            NSWorkspace.shared.open(fileURL)
        } catch {
            write("Failed to open log: \(error.localizedDescription)")
        }
    }

    static func copyLog() -> Bool {
        do {
            let contents = try String(
                contentsOf: fileURL,
                encoding: .utf8
            )

            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(
                contents,
                forType: .string
            )

            write("Diagnostic log copied to clipboard.")
            return true
        } catch {
            write("Failed to read diagnostic log: \(error.localizedDescription)")
            return false
        }
    }

    static func logPath() -> String {
        fileURL.path
    }
}

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
#if canImport(IOKit)
import IOKit.ps
#endif
#if os(macOS)
import Darwin
#endif

// MARK: - Live Data Providers

public final class LiveDataProvider: ObservableObject {
    public static let shared = LiveDataProvider()

    @Published public var batteryLevel: Int = 100
    @Published public var ramUsedPercent: Int = 0
    @Published public var weatherTemp: String = "--°"
    @Published public var weatherCond: String = "—"
    @Published public var musicTitle: String = "Not Playing"
    @Published public var musicArtist: String = "—"

    private var weatherLastFetch: Date? = nil
    private var weatherCache: (temp: String, cond: String)? = nil
    private var timer: Timer?

    public init() {
        refreshAll()
    }

    public func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.refreshAll()
        }
    }

    public func refreshAll() {
        refreshBattery()
        refreshRAM()
        refreshMusic()
        refreshWeatherIfNeeded()
    }

    public func refreshBattery() {
        #if canImport(IOKit) && os(macOS)
        let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] ?? []
        for ps in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, ps)?.takeUnretainedValue() as? [String: Any],
               let cap = desc[kIOPSCurrentCapacityKey as String] as? Int {
                DispatchQueue.main.async { self.batteryLevel = cap }
                return
            }
        }
        #endif
        DispatchQueue.main.async { self.batteryLevel = 100 }
    }

    public func refreshRAM() {
        #if os(macOS)
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let pageSize = Double(vm_kernel_page_size)
            let active = Double(stats.active_count) * pageSize
            let wired = Double(stats.wire_count) * pageSize
            let compressed = Double(stats.compressor_page_count) * pageSize
            let used = active + wired + compressed
            let total = Double(ProcessInfo.processInfo.physicalMemory)
            let pct = total > 0 ? Int((used / total) * 100.0) : 0
            DispatchQueue.main.async { self.ramUsedPercent = min(100, max(0, pct)) }
        }
        #endif
    }

    public func refreshMusic() {
        #if os(macOS)
        let script = """
        tell application "System Events"
            set musicRunning to (name of processes) contains "Music"
            set spotifyRunning to (name of processes) contains "Spotify"
        end tell
        if musicRunning then
            tell application "Music"
                if player state is playing then
                    return (name of current track) & "||" & (artist of current track)
                end if
            end tell
        end if
        if spotifyRunning then
            tell application "Spotify"
                if player state is playing then
                    return (name of current track) & "||" & (artist of current track)
                end if
            end tell
        end if
        return "Not Playing||—"
        """
        let result = runAppleScript(script)
        let parts = result.components(separatedBy: "||")
        let title = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Not Playing"
        let artist = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : "—"
        DispatchQueue.main.async {
            self.musicTitle = title.isEmpty ? "Not Playing" : title
            self.musicArtist = artist.isEmpty ? "—" : artist
        }
        #endif
    }

    private func runAppleScript(_ source: String) -> String {
        #if os(macOS)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", source]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? "Not Playing||—"
        } catch {
            return "Not Playing||—"
        }
        #else
        return "Not Playing||—"
        #endif
    }

    public func refreshWeatherIfNeeded(force: Bool = false) {
        if !force, let last = weatherLastFetch, Date().timeIntervalSince(last) < 600, weatherCache != nil {
            return
        }
        // Seattle default fallback; Open-Meteo can work without key. We use a fixed coord
        // for simplicity; a real app would geolocate. This keeps it reliable in sandbox.
        let lat = 47.6062
        let lon = -122.3321
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weather_code&temperature_unit=fahrenheit&timezone=auto"
        guard let url = URL(string: urlStr) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let current = json["current"] as? [String: Any] else { return }
            let tempVal = current["temperature_2m"] as? Double ?? 0
            let code = current["weather_code"] as? Int ?? 0
            let temp = "\(Int(round(tempVal)))°F"
            let cond = Self.weatherCodeToString(code)
            DispatchQueue.main.async {
                self.weatherTemp = temp
                self.weatherCond = cond
                self.weatherCache = (temp, cond)
                self.weatherLastFetch = Date()
            }
        }
        task.resume()
    }

    public static func weatherCodeToString(_ code: Int) -> String {
        switch code {
        case 0: return "Clear"
        case 1: return "Mostly Clear"
        case 2: return "Partly Cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 56, 57: return "Freezing Drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing Rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow Grains"
        case 80, 81, 82: return "Showers"
        case 85, 86: return "Snow Showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm+Hail"
        default: return "Cloudy"
        }
    }
}

// MARK: - FormulaEngine

public struct FormulaEngine {
    public static func evaluate(_ input: String, provider: LiveDataProvider = .shared, date: Date = Date()) -> String {
        var result = input
        // $df(...)$
        let dfPattern = "\\$df\\(([^\\)]*)\\)\\$"
        if let regex = try? NSRegularExpression(pattern: dfPattern) {
            let ns = result as NSString
            let matches = regex.matches(in: result, range: NSRange(location: 0, length: ns.length)).reversed()
            for m in matches {
                guard m.numberOfRanges >= 2 else { continue }
                let fmt = ns.substring(with: m.range(at: 1))
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                formatter.dateFormat = fmt
                let replacement = formatter.string(from: date)
                result = (result as NSString).replacingCharacters(in: m.range(at: 0), with: replacement)
            }
        }

        // Simple token replacements
        let tokens: [(String, () -> String)] = [
            ("$bi(level)$", { "\(provider.batteryLevel)%" }),
            ("$rm(cused)$", { "\(provider.ramUsedPercent)%" }),
            ("$wi(temp)$", { provider.weatherTemp }),
            ("$wi(cond)$", { provider.weatherCond }),
            ("$mi(title)$", { provider.musicTitle }),
            ("$mi(artist)$", { provider.musicArtist }),
        ]
        for (token, value) in tokens {
            if result.contains(token) {
                result = result.replacingOccurrences(of: token, with: value())
            }
        }
        return result
    }

    public static func containsFormula(_ input: String) -> Bool {
        input.contains("$df(") || input.contains("$bi(") || input.contains("$rm(") ||
        input.contains("$wi(") || input.contains("$mi(")
    }
}

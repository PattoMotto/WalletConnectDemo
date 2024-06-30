import OSLog

enum DevelopmentLog {
    static func debug(_ message: String) {
        Logger.development.debug("\(message, privacy: .private)")
    }

    static func error(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        Logger.development.error("\(message, privacy: .private) \(file, privacy: .private) \(line, privacy: .private) \(function, privacy: .private)")
    }
}

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let development = Logger(subsystem: subsystem, category: "development")
}

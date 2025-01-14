import Foundation

extension Bundle {
    var version: Version? { Version(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) }
    var versionName: String { (version?.description ?? "0.0.0") + (ProcessInfo.dev ? "-dev" : "") }
}

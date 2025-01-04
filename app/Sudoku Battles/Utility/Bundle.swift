import Foundation

extension Bundle {
    var dev: Bool { self.object(forInfoDictionaryKey: "Dev") as? String == "YES" }
    var version: Version? { Version(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) }
    var versionName: String { (version?.description ?? "0.0.0") + (dev ? "-dev" : "") }
}

import Foundation

extension Bundle {
    var dev: Bool { self.object(forInfoDictionaryKey: "Dev") as? String == "YES" }
    var firebaseHost: String { "192.168.1.13" }
    var functionsPort: Int { 5001 }
    var firestorePort: Int { 8080 }
    var authenticationPort: Int { 9099 }
    var storagePort: Int { 9199 }

    
    var version: Version? { Version(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) }
    var versionName: String { (version?.description ?? "0.0.0") + (dev ? "-dev" : "") }
}

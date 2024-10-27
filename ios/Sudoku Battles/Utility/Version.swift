import Foundation
 
struct Version: Equatable {
    
    static let zero = Version(0, 0, 0)
    
    let major: Int
    let minor: Int
    let patch: Int
    
    func isNewer(than other: Version) -> Bool {
        if self.major != other.major {
            return self.major > other.major
        } else if self.minor != other.minor {
            return self.minor > other.minor
        } else {
            return self.patch > other.patch
        }
    }
 
    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    init?(_ versionString: String?) {
        guard let versionString else { return nil }
        
        let pattern = #"(\d+)\.(\d+)(?:\.(\d+))?"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsRange = NSRange(versionString.startIndex..<versionString.endIndex, in: versionString)
        
        if let match = regex.firstMatch(in: versionString, options: [], range: nsRange) {
            if let majorRange = Range(match.range(at: 1), in: versionString),
               let minorRange = Range(match.range(at: 2), in: versionString) {
                
                let majorString = String(versionString[majorRange])
                let minorString = String(versionString[minorRange])
                let patchString: String
 
                if let patchRange = Range(match.range(at: 3), in: versionString) {
                    patchString = String(versionString[patchRange])
                } else {
                    patchString = "0"
                }
 
                if let major = Int(majorString), let minor = Int(minorString), let patch = Int(patchString) {
                    self.major = major
                    self.minor = minor
                    self.patch = patch
                    return
                }
            }
        }
        return nil
    }
 
    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major &&
               lhs.minor == rhs.minor &&
               lhs.patch == rhs.patch
    }
}
 
 
 
extension Version: CustomStringConvertible {
    var description: String {
        return String(self)
    }
}
 
extension String {
    init(_ version: Version) {
        self.init("\(version.major).\(version.minor).\(version.patch)")
    }
}

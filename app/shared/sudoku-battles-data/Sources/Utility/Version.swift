//
//  Version.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/5/25.
//

import Foundation
import SimpleBuffers

public struct Version: Codable, Equatable {
    nonisolated(unsafe) public static let zero = Version(0, 0, 0)

    public let major: Int
    public let minor: Int
    public let patch: Int

    public func isNewer(than other: Version) -> Bool {
        if major != other.major {
            return major > other.major
        } else if minor != other.minor {
            return minor > other.minor
        } else {
            return patch > other.patch
        }
    }

    public init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init?(_ versionString: String?) {
        guard let versionString else { return nil }

        let pattern = #"(\d+)\.(\d+)(?:\.(\d+))?"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsRange = NSRange(versionString.startIndex..<versionString.endIndex, in: versionString)

        if let match = regex.firstMatch(in: versionString, options: [], range: nsRange) {
            if let majorRange = Range(match.range(at: 1), in: versionString),
                let minorRange = Range(match.range(at: 2), in: versionString)
            {
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

    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

public extension Version {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let major = try container.decode(VarInt.self)
        let minor = try container.decode(VarInt.self)
        let patch = try container.decode(VarInt.self)
        
        self.major = Int(major.value)
        self.minor = Int(minor.value)
        self.patch = Int(patch.value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(VarInt(major))
        try container.encode(VarInt(minor))
        try container.encode(VarInt(patch))
    }
}

public extension String {
    init(_ version: Version) {
        self.init("\(version.major).\(version.minor).\(version.patch)")
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

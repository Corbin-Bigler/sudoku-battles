//
//  Version.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/5/25.
//

import Meow
import Foundation
import SimpleBuffers

public struct VersionEntity: Codable {
    public let releasedAt: Date
    public let version: Version
    public let minimumAppVersions: AppVersions
    @Wrap public var gitHash: String?
    
    public init(releasedAt: Date, version: Version, minimumAppVersions: AppVersions, gitHash: String? = nil) {
        self.releasedAt = releasedAt
        self.version = version
        self.minimumAppVersions = minimumAppVersions
        self.gitHash = gitHash
    }
    
    public struct AppVersions: Codable {
        public let ios: Version
        public let android: Version
        public let web: Version
        
        public init(ios: Version, android: Version, web: Version) {
            self.ios = ios
            self.android = android
            self.web = web
        }
    }
}

//
//  ProcessInfo.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

import Foundation

extension ProcessInfo {
    static var dev: Bool { Self.processInfo.environment["DEV"] == "1" }
    static var firebaseHost: String { Self.processInfo.environment["FIREBASE_HOST"]! }
    static var functionsPort: Int { Int(Self.processInfo.environment["FUNCTIONS_PORT"]!)! }
    static var firestorePort: Int { Int(Self.processInfo.environment["FIRESTORE_PORT"]!)! }
    static var authenticationPort: Int { Int(Self.processInfo.environment["AUTHENTICATION_PORT"]!)! }
    static var storagePort: Int { Int(Self.processInfo.environment["STORAGE_PORT"]!)! }
}

//
//  UserSetUsernameService.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/12/25.
//

import Piste
import Foundation

public struct UserSetUsernameService: PisteService, Sendable {
    public static let function: PisteFunction = "user-set-username"
    public static let version: Int = 1
    
    public struct ServerBound: Codable, Sendable {
        public let username: String
        public init(username: String) {
            self.username = username
        }
    }
    
    public typealias ClientBound = EmptyCodable
}

//
//  UserSetUsernameService.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/12/25.
//

import Piste
import Foundation

public struct CreateUserService: PisteService {
    public typealias ServerBound = EmptyCodable
    public typealias ClientBound = ClientBoundPayload
    
    public static let function: PisteFunction = "user-set-username"
    public static let version: Int = 1
    
    public struct ServerBoundPayload: Codable, Sendable {
        public let username: String
        public init(username: String) {
            self.username = username
        }
    }
    public struct ClientBoundPayload: Codable, Sendable {
        public let status: Status
        public init(status: Status) {
            self.status = status
        }
        
        public enum Status: String, Codable, Sendable {
            case usernameInUse = "username-in-use"
            case usernameDebounce = "username-debounce"
            case success = "success"
        }
    }
}

public struct UserSetUsernameService: PisteService, Sendable {
    public typealias ServerBound = ServerBoundPayload
    public typealias ClientBound = ClientBoundPayload
    
    public static let function: PisteFunction = "user-set-username"
    public static let version: Int = 1
    
    public struct ServerBoundPayload: Codable, Sendable {
        public let username: String
        public init(username: String) {
            self.username = username
        }
    }
    public struct ClientBoundPayload: Codable, Sendable {
        public let status: Status
        public init(status: Status) {
            self.status = status
        }
        
        public enum Status: String, Codable, Sendable {
            case usernameInUse = "username-in-use"
            case usernameDebounce = "username-debounce"
            case success = "success"
        }
    }
}

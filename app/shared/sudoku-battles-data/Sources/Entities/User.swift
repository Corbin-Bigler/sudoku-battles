//
//  User.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import Foundation
import Meow
import Hardpack

public struct User: Model, Codable, Sendable {
    @Field public var _id: UUID
    @Field @Nullable public var username: String?
    @Field @Nullable public var usernameChangedAt: Date?
    @Field public var ranking: Int
    @Field public var admin: Bool
    @Field public var devices: [Device]
    
    public init(id: UUID, username: String? = nil, usernameChangedAt: Date? = nil, ranking: Int, admin: Bool, devices: [Device]) {
        self._id = id
        self.username = username
        self.usernameChangedAt = usernameChangedAt
        self.ranking = ranking
        self.admin = admin
        self.devices = devices
    }
}


//
//  Device.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/16/25.
//

import Meow
import Foundation

public struct Device: Model, Codable, Sendable {
    @Field public var _id: UUID
    @Field public var fcmToken: Binary?
    
    public init(id: UUID, fcmToken: Binary? = nil) {
        self._id = id
        self.fcmToken = fcmToken
    }
}

//
//  User.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import Foundation
import Meow

struct User: Model, Codable {
    @Field var _id: UUID
    @Field var username: String?
    @Field var admin: Bool
    @Field var admin: Bool
}

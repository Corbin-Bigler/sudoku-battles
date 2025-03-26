//
//  MongoDs.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import MongoKitten
import Meow

final class MongoDs: Sendable {
    static let password = "sogvof-hymcYk-3mivxa"
    let db: MeowDatabase

    init() async throws {
        self.db = MeowDatabase(try await MongoDatabase.connect(to: "mongodb+srv://thysmesi:\(Self.password)@cluster0.ipwso.mongodb.net/sudoku_battles"))
    }
}

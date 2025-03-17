//
//  MongoDs.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import MongoKitten

final class MongoDs: Sendable {
    static let password = "sogvof-hymcYk-3mivxa"
    let db: MongoDatabase

    init() async throws {
        self.db = try await MongoDatabase.connect(to: "mongodb+srv://thysmesi:\(Self.password)@cluster0.ipwso.mongodb.net/sudoku_battles")
    }
    
    func insertUser() async throws {
        try await db["users"].insert(["name": "Alice", "age": 30])
    }
}

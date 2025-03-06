//
//  MongoDbDs.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/5/25.
//

import MongoKitten

class MongoDbDs: DatabaseDs {
    
    let url: String
    private var db: MongoDatabase?
    
    init(url: String) {
        self.url = url
    }
    
    func connect() async throws {
        self.db = try await MongoDatabase.connect(to: url)
    }

    func disconnect() {
        db = nil
    }
    
}

class VersionRepo {
    private let db: DatabaseDs

    init(db: DatabaseDs) { self.db = db }
}

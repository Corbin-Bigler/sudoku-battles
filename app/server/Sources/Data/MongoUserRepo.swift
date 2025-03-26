//
//  MongoUserRepo.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/17/25.
//

import MongoKitten
import SudokuBattlesData

extension MongoDs: UserRepo {
    func insert(user: SudokuBattlesData.User) async throws {
        try (try await User.save(user)(in: db)).assertCompleted()
    }
}
